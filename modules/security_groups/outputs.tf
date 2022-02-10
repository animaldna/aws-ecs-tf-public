output "alb_public_sg" {
  value = module.alb_public_sg.security_group_id
}

output "ecs_protected_sg" {
  value = module.ecs_protected_sg.security_group_id
}

output "endpoints_sg" {
  value = module.vpc_endpoints_sg.security_group_id
}