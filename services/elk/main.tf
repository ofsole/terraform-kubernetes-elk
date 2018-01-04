module "elasticsearch" {
  source       = "../../modules/elasticsearch"
  environment  = "${terraform.workspace}"
}
module "logstash" {
  source       = "../../modules/logstash"
  environment  = "${terraform.workspace}"
}
/**
module "kibana" {
  source       = "../../modules/kibana"
  environment  = "${terraform.workspace}"
}
**/
