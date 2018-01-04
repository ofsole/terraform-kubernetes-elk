resource "kubernetes_service" "elasticsearch" {
  metadata {
    name = "elasticsearch"
  }
  spec {
    selector {
      app = "${kubernetes_replication_controller.elasticsearch.metadata.0.labels.app}"
    }
    port {
      name = "rest-api"
      port = 9200
      target_port = 9200
    }
    port {
      name = "cluster-api"
      port = 9300
      target_port = 9300
    }
    type = "ClusterIP"
  }
}

