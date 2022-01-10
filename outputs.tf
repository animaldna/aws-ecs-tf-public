output "resource_prefix" {
  value = local.resource_prefix
}

output "service_url" {
  value = "${local.resource_prefix}.${var.domain_name}"
}

output "alb_dns_hostname" {
  value = module.service_alb.alb_dns_name
}