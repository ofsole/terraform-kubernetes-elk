resource "kubernetes_config_map" "consul" {
  metadata {
    name = "consul-cm"
  }

  data {
    acl_datacenter.json = "{ \"acl_datacenter\": \"${var.environment}\", \"acl_master_token\": \"${var.consul_master_token["${terraform.workspace}"]}\", \"acl_agent_token\": \"${var.consul_master_token["${terraform.workspace}"]}\", \"acl_default_policy\": \"deny\", \"acl_down_policy\": \"deny\" }"
  }
}

