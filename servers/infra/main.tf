provider "aws" {
  profile = "leedonggyu"
  region  = "ap-northeast-2"
}

terraform {
  backend "s3" {
    bucket  = "dk-state-bucket"
    key     = "ecs"
    region  = "ap-northeast-2"
    profile = "leedonggyu"
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket  = "dk-state-bucket"
    key     = "network"
    region  = "ap-northeast-2"
    profile = "leedonggyu"
  }
}

locals {
  vpc = data.terraform_remote_state.network.outputs.out.vpc

  vpc_id            = local.vpc.vpc_id
  regions           = local.vpc.regions
  webserver_subnets = local.vpc.webserver_subnets
  was_subnets       = local.vpc.was_subnets
}

output "aa" {
  value = local.vpc
}