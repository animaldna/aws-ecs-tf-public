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
      env = var.env
      # env_id  = random_string.env_id.result
      project = local.project_name
      foo     = "bar"
    }
  }
}

# resource "random_string" "env_id" {
#   length  = 5
#   special = false
#   number  = true
#   lower   = true
#   upper   = false
# }

module "data" {
  source      = "./modules/data"
  domain_name = var.domain_name
}

locals {
  project_name = "catalog-api"
  # resource_prefix = "${var.env}-${random_string.env_id.result}-${local.project_name}"
  resource_prefix = "${var.env}-${local.project_name}"
  max_capacity    = var.env == "prod" ? 4 : 2
  min_capacity    = var.env == "prod" ? 2 : 1
  i_endpoints     = ["ecr.api", "ecr.dkr", "logs", "elasticloadbalancing"]
}

module "vpc" {
  source          = "./modules/vpc"
  region          = var.aws_region
  vpc_cidr        = lookup(var.vpc_cidr, var.env, "dev")
  safe_ips        = var.safe_ips
  azs             = module.data.azs
  resource_prefix = local.resource_prefix
}

module "vpc_endpoints" {
  source       = "./modules/vpc_endpoints"
  region       = var.aws_region
  vpc_id       = module.vpc.vpc_id
  endpoints_sg = module.security_groups.endpoints_sg
  i_endpoints  = local.i_endpoints
  # public_subnets  = module.vpc.public_subnets
  # private_subnets = module.vpc.private_subnets
  private_rts = module.vpc.private_rts
  public_rts  = module.vpc.public_rts
  depends_on  = [module.vpc]
}

module "security_groups" {
  source          = "./modules/security_groups"
  resource_prefix = local.resource_prefix
  vpc_id          = module.vpc.vpc_id
  region          = var.aws_region
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
  name    = var.env == "prod" ? local.project_name : local.resource_prefix
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
  private_subnets  = module.vpc.private_subnets
  region           = var.aws_region
  default_image    = var.default_image
}

module "ecs_autoscaling" {
  source          = "./modules/ecs_autoscaling"
  resource_prefix = local.resource_prefix
  max_capacity    = local.max_capacity
  min_capacity    = local.min_capacity
  env             = var.env
  depends_on      = [module.ecs]
}