output "azs" {
  value = data.aws_availability_zones.azs.names
}

output "cert" {
  value = data.aws_acm_certificate.cert.arn
}

output "dns_zone" {
  value = data.aws_route53_zone.zone.zone_id
}