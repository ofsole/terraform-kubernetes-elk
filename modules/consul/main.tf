resource "kubernetes_pod" "consul" {
  metadata {
    name = "consul-master"
    labels {
      app = "consul-master"
    }
  }

  spec {
    container {
      image = "consul:1.0.0"
      name  = "consul-master"
      image_pull_policy = "Always"
      args = [
        "agent",
        "-server",
        "-advertise=$(POD_IP)",
        "-bootstrap-expect=3",
#        "-encrypt=$(GOSSIP_ENCRYPTION_KEY)",
        "-disable-host-node-id=true",
        "-recursor=114.114.114.114",
        "-datacenter=${var.environment}",
        "-client=0.0.0.0",
        "-ui"]
      env = {
        name = "POD_IP"
        value_from = {
          field_ref = {
            field_path = "status.podIP"
          }
        }
      }
      env = {
        name = "NAMESPACE"
        value_from = {
          field_ref = {
            field_path = "metadata.namespace"
          }
        }
      }
      env = {
        name = "GOSSIP_ENCRYPTION_KEY"
        value_from = {
          secret_key_ref = {
            name = "consul-server"
            key = "${terraform.workspace}-gossip-encryption-key"
          }
        }
      }
      env = {
        name = "CONSUL_HTTP_TOKEN"
        value_from = {
          secret_key_ref = {
            name = "consul-server"
            key = "${terraform.workspace}-acl-master-token"
          }
        }
      }
      port = {
        container_port = 8500
      }
      port = {
        container_port = 8300
      }
      port = {
        container_port = 8301
      }
      volume_mount {
        name = "consul-cm-volume"
        mount_path = "/consul/config"
      }
    }
    hostname = "consul-master"
    subdomain = "${terraform.workspace}"
    restart_policy = "Always"
    volume {
      name = "consul-cm-volume"
      config_map = {
        name = "${kubernetes_config_map.consul.metadata.0.name}"
        default_mode = 0655
      }
    }
  }
}

resource "kubernetes_replication_controller" "consul" {
  depends_on = ["kubernetes_pod.consul"]
  metadata {
    name = "consul"
    labels {
      app = "consul"
    }
  }

  spec {
    selector {
      app = "consul"
    }
    replicas = "${var.count}"
    template {
      container {
        image = "consul:1.0.0"
        name  = "consul"
        image_pull_policy = "Always"
        args = [
          "agent",
          "-server",
          "-advertise=$(POD_IP)",
          "-bootstrap-expect=${var.count + 1}",
#          "-encrypt=$(GOSSIP_ENCRYPTION_KEY)",
          "-disable-host-node-id=true",
          "-retry-join=consul-master.${terraform.workspace}.$(NAMESPACE).svc.cluster.local",
          "-recursor=114.114.114.114",
          "-datacenter=${var.environment}",
          "-client=0.0.0.0",
          "-ui"]
        env = {
          name = "POD_IP"
          value_from = {
            field_ref = {
              field_path = "status.podIP"
            }
          }
        }
        env = {
          name = "NAMESPACE"
          value_from = {
            field_ref = {
              field_path = "metadata.namespace"
            }
          }
        }
        env = {
          name = "GOSSIP_ENCRYPTION_KEY"
          value_from = {
            secret_key_ref = {
              name = "consul-server"
              key = "${terraform.workspace}-gossip-encryption-key"
            }
          }
        }
        env = {
          name = "CONSUL_HTTP_TOKEN"
          value_from = {
            secret_key_ref = {
              name = "consul-server"
              key = "${terraform.workspace}-acl-master-token"
            }
          }
        }
        lifecycle = {
          pre_stop = {
            exec = {
              command = [
                "/bin/sh",
                "-c",
                "consul leave"
                        ]
            }
          }
        }
        port = {
          container_port = 8500
        }
        port = {
          container_port = 8300
        }
        port = {
          container_port = 8301
        }
        volume_mount {
          name = "consul-cm-volume"
          mount_path = "/consul/config"
        }
      }
      volume {
        name = "consul-cm-volume"
        config_map = {
          name = "${kubernetes_config_map.consul.metadata.0.name}"
          default_mode = 0655
        }
      }
      restart_policy = "Always"
    }
  }

}

resource "null_resource" "init-agent-token" {
  depends_on = ["kubernetes_service.consul"]
  provisioner "local-exec" {
    command = <<EOF
kubectl exec -it consul-master -- curl \
    --request PUT \
    --header "X-Consul-Token: ${var.consul_master_token["${terraform.workspace}"]}" \
    --data \
'{
  "Name": "Agent Token",
  "Type": "client",
  "Rules": "node \"\" { policy = \"write\" } service \"\" { policy = \"write\" } key \"\" { policy = \"write\" } agent \"\" { policy = \"write\" }"
}' http://127.0.0.1:8500/v1/acl/create |  awk -F '"' '{print $4}' > /tmp/agent_token
sed -i "s/${terraform.workspace}-acl-agent.*/${terraform.workspace}-acl-agent-token = \"$(cat /tmp/agent_token)\"/g" ../../modules/consul/secret.tf
EOF
  }
}
