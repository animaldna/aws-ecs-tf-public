locals {
  private_subnets = [
    for i, az in var.azs :
    cidrsubnet(var.vpc_cidr, 5, i)
  ]
  public_subnets = [
    for i, az in var.azs :
    cidrsubnet(var.vpc_cidr, 5, length(var.azs) + i)
  ]
  public_inbound_http = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 101
      rule_action = "allow"
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    },
    {
      rule_number = 102
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  ]
  public_inbound_ssh = [
    for i, ip in var.safe_ips :
    {
      rule_number = 103 + i
      rule_action = "allow"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_block  = ip
    }
  ]
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "2.21.0"

  name                 = "${var.resource_prefix}-vpc"
  cidr                 = var.vpc_cidr
  azs                  = var.azs
  public_subnets       = local.public_subnets
  private_subnets      = local.private_subnets
  enable_dns_hostnames = true

  private_dedicated_network_acl = true
  private_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 1024
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  ]
  public_dedicated_network_acl = true
  # @TODO - FIX THIS
  # private_inbound_acl_rules    = templatefile("${path.module}/templates/public_in_nacl.tfpl", { safe_ips = var.safe_ips })
  public_inbound_acl_rules = concat(local.public_inbound_http, local.public_inbound_ssh)
  public_outbound_acl_rules = [
    {
      rule_number = 100
      rule_action = "allow"
      from_port   = 0
      to_port     = 65535
      protocol    = "tcp"
      cidr_block  = "0.0.0.0/0"
    }
  ]
}
