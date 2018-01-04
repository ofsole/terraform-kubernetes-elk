resource "kubernetes_secret" "consul-server" {
  metadata {
    name = "consul-server"
  }

  data {
    qa-acl-master-token = "x-x-x-x-x"
    stg-acl-master-token = "x-x-x-x-x"
    prod-acl-master-token = "x-x-x-x-x"
  }

  type = "Opaque"
}

resource "kubernetes_secret" "consul-agent" {
  depends_on = ["null_resource.init-agent-token"]
  metadata {
    name = "consul-agent"
  }

  data {
    qa-acl-agent-token = "x-x-x-x-x"
    stg-acl-agent-token = "x-x-x-x-x"
    prod-acl-agent-token = "x-x-x-x-x"
  }

  type = "Opaque"
}

resource "kubernetes_secret" "consul-gossip-key" {
  metadata {
    name = "consul-gossip-key"
  }

  data {
    qa-gossip-encryption-key = "xxx"
    stg-gossip-encryption-key = "xxx"
    prod-gossip-encryption-key = "xxx"
  }

  type = "Opaque"
}
