output "target_group_arn" {
  value = aws_lb_target_group.service_target_group.arn
}

output "alb_dns_name" {
  value = aws_lb.service_alb.dns_name
}

output "alb_zone_id" {
  value = aws_lb.service_alb.zone_id
}