resource "kubernetes_service" "logstash" {
  metadata {
    name = "logstash"
  }
  spec {
    selector {
      app = "${kubernetes_replication_controller.logstash.metadata.0.labels.app}"
    }
    port {
      name = "logstash-tcp"
      port = 5000
      target_port = 5000
    }
    port {
      name = "logstash-udp"
      port = 5000
      protocol = "UDP"
      target_port = 5000
    }
    type = "ClusterIP"
  }
}

