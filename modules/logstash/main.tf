resource "kubernetes_replication_controller" "logstash" {
  metadata {
    name = "logstash"
    labels {
      app = "logstash"
    }
  }

  spec {
    selector {
      app = "logstash"
    }
    replicas = 1
    template {
      container {
        name  = "logstash"
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
          name = "LS_JAVA_OPTS"
          value = "-Xms1024m -Xmx1024m"
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
          container_port = 5000
        }
        port = {
          container_port = 5000
          protocol = "UDP"
        }
      }
      restart_policy = "Always"
      image_pull_secrets = {
        name = "regsecret"
     } 
    }
  }
}
