resource "kubernetes_service" "kibana" {
  metadata {
    name = "kibana"
  }
  spec {
    selector {
      app = "${kubernetes_replication_controller.kibana.metadata.0.labels.app}"
    }
    port {
      name = "kibana"
      port = 5601
      target_port = 5601
    }
    type = "NodePort"
  }
}

