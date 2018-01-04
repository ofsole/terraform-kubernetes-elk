resource "kubernetes_service" "consul" {
  depends_on = ["kubernetes_replication_controller.consul"]
  provisioner "local-exec" {
    command = "sleep 10"
  }
  metadata {
    name = "consul"
  }
  spec {
    selector {
      app = "${kubernetes_replication_controller.consul.metadata.0.labels.app}"
    }
    port {
      name = "consul-ui"
      port = 8500
      target_port = 8500
    }
    port {
      name = "consul-rpc"
      port = 8300
      target_port = 8300
    }
    port {
      name = "serf-lan"
      port = 8301
      target_port = 8301
    }
    type = "LoadBalancer"
  }
}

resource "kubernetes_service" "consul-master" {
  metadata {
    name = "${terraform.workspace}"
  }
  spec {
    selector {
      app = "consul-master"
    }
    cluster_ip = "None"
    port {
      name = "consul" # Actually, no port is needed.
      port = 1234 
      target_port = 1234
    }
  }
}

