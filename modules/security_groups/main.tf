data "aws_prefix_list" "ddb_pl" {
  name = "com.amazonaws.${var.region}.dynamodb"
}

data "aws_prefix_list" "s3_pl" {
  name = "com.amazonaws.${var.region}.s3"
}

module "alb_public_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.7.0"

  create_sg   = true
  name        = "${var.resource_prefix}-alb_public_sg"
  description = "Public SG for ALB. Inbound traffic on 80 & 443. Outbound to all."
  vpc_id      = var.vpc_id

  ingress_cidr_blocks = ["0.0.0.0/0"]
  egress_cidr_blocks  = ["0.0.0.0/0"]


  ingress_rules = ["http-80-tcp", "https-443-tcp"]

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.ecs_protected_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 1

  egress_rules = ["all-all"]
  tags = {
    tier = "public"
  }
}

module "vpc_endpoints_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.7.0"

  create_sg   = true
  name        = "${var.resource_prefix}-vpc_endpoints_sg"
  description = "Security group for VPC endpoints"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = 6
      description = "All TCP on all ports"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "ecs_protected_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "4.7.0"

  create_sg   = true
  name        = "${var.resource_prefix}-ecs_protected_sg"
  description = "Protected SG for ECS. Inbound traffic from ALB SG. Outbound to all."
  vpc_id      = var.vpc_id

  computed_ingress_with_source_security_group_id = [
    {
      rule                     = "all-all"
      source_security_group_id = module.alb_public_sg.security_group_id
    },
    {
      rule                     = "all-all"
      source_security_group_id = module.vpc_endpoints_sg.security_group_id
    }
  ]
  number_of_computed_ingress_with_source_security_group_id = 2

  ingress_prefix_list_ids = [data.aws_prefix_list.ddb_pl.id, data.aws_prefix_list.s3_pl.id, ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 65535
      protocol    = 6
      description = "Allow all traffic out of this subnet"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = {
    tier = "private"
  }
}

