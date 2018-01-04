resource "kubernetes_replication_controller" "elasticsearch" {
  metadata {
    name = "elasticsearch"
    labels {
      app = "elasticsearch"
    }
  }

  spec {
    selector {
      app = "elasticsearch"
    }
    replicas = 1
    template {
      container {
        name  = "elasticsearch"
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
        env = {
          name = "ES_JAVA_OPTS"
          value = "-Xms1024m -Xmx1024m"
        }
        image_pull_policy = "Always"
        port = {
          container_port = 9200
        }
        port = {
          container_port = 9300
        }

      }
      restart_policy = "Always"
      image_pull_secrets = {
        name = "regsecret"
     } 
    }
  }
}
