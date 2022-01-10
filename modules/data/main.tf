data "aws_availability_zones" "azs" {
  state = "available"
}

data "aws_acm_certificate" "cert" {
  domain = var.domain_name
}

data "aws_route53_zone" "zone" {
  name = var.domain_name
}