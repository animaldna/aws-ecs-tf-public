output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnets" {
  value = module.vpc.public_subnets
}

output "private_subnets" {
  value = module.vpc.private_subnets
}

output "public_rts" {
  value = module.vpc.public_route_table_ids
}

output "private_rts" {
  value = module.vpc.private_route_table_ids
}