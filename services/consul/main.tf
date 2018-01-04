module "consul" {
  source       = "../../modules/consul"
  environment  = "${terraform.workspace}"
}
