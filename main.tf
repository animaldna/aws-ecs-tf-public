terraform {
  backend "s3" {}
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.7"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = {
      env     = var.env
      env_id  = random_string.env_id.result
      project = var.project_name
    }
  }
}

resource "random_string" "env_id" {
  length  = 5
  special = false
  number  = true
  lower   = true
  upper   = false
}

module "data" {
  source      = "./modules/data"
  domain_name = var.domain_name
}

locals {
  resource_prefix = "${var.env}-${random_string.env_id.result}-${var.project_name}"
}

module "vpc" {
  source          = "./modules/vpc"
  vpc_cidr        = lookup(var.vpc_cidr, var.env, "dev")
  safe_ips        = var.safe_ips
  azs             = module.data.azs
  resource_prefix = local.resource_prefix
}

module "security_groups" {
  source          = "./modules/security_groups"
  resource_prefix = local.resource_prefix
  vpc_id          = module.vpc.vpc_id
}

module "service_alb" {
  source          = "./modules/service_alb"
  resource_prefix = local.resource_prefix
  env             = var.env
  aws_account_id  = var.aws_account_id
  public_subnets  = module.vpc.public_subnets
  vpc_id          = module.vpc.vpc_id
  security_groups = [module.security_groups.alb_public_sg]
  acm_cert        = module.data.cert
}

resource "aws_route53_record" "service_domain" {
  zone_id = module.data.dns_zone
  name    = local.resource_prefix
  type    = "A"

  alias {
    name                   = module.service_alb.alb_dns_name
    zone_id                = module.service_alb.alb_zone_id
    evaluate_target_health = true
  }
}

module "ecs" {
  source           = "./modules/ecs"
  resource_prefix  = local.resource_prefix
  security_groups  = [module.security_groups.ecs_protected_sg]
  env              = var.env
  alb_target_group = module.service_alb.target_group_arn
  public_subnets   = module.vpc.public_subnets
  image            = var.image
  region           = var.aws_region
}