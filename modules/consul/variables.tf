variable "environment" {
  default = "qa"
}

variable "count" {
  default = 2
}

variable "consul_master_token" {
  type = "map"

  default = {
      qa     =  "2fad8b14-bf5d-bd91-9414-941e3bca1a7c"
      stg    =  "692b584b-84e8-4235-99cc-01c8e0a9db91"
      prod   =  "7e1c0a74-7ad7-4b3f-8fa9-cfd038e43ca0"
  }
}

