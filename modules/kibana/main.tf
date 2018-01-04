resource "kubernetes_replication_controller" "kibana" {
  metadata {
    name = "kibana"
    labels {
      app = "kibana"
    }
  }

  spec {
    selector {
      app = "kibana"
    }
    replicas = 1
    template {
      container {
        name  = "kibana"
        image = "add custom image here"
        env = {
          name = "CONSUL_DC"
          value = "${var.environment}"
        }
        env = {
          name = "CONSUL_HOST"
          value = "consul"
        }
        env = {
          name = "CONSUL_SECURE"
          value = 1
        }
        env = {
          name = "CONSUL_HTTP_TOKEN"
          value_from = {
            secret_key_ref = {
              name = "consul-agent"
              key = "${terraform.workspace}-acl-agent-token"
            }
          }
        }
        image_pull_policy = "Always"
        port = {
          container_port = 5601
        }
        readiness_probe = {
          tcp_socket = {
            port = 5601  
          }
          initial_delay_seconds = 5
          period_seconds = 10
        }
      }
      restart_policy = "Always"
      image_pull_secrets = {
        name = "regsecret"
     } 
    }
  }
}
