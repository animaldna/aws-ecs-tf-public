# data "aws_route_tables" "routes" {
#   vpc_id = var.vpc_id
# }

locals {
  route_table_ids = concat(var.public_rts, var.private_rts)
}


resource "aws_vpc_endpoint" "s3" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.s3"
}

resource "aws_vpc_endpoint" "ddb" {
  vpc_id       = var.vpc_id
  service_name = "com.amazonaws.${var.region}.dynamodb"
}

resource "aws_vpc_endpoint_route_table_association" "s3-pl" {
  count = length(local.route_table_ids)

  route_table_id  = local.route_table_ids[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.s3.id
}

resource "aws_vpc_endpoint_route_table_association" "ddb-pl" {
  count = length(local.route_table_ids)

  route_table_id  = local.route_table_ids[count.index]
  vpc_endpoint_id = aws_vpc_endpoint.ddb.id
}

# resource "aws_vpc_endpoint_route_table_association" "s3-pl-public" {
#   for_each = toset(var.public_subnets)

#   route_table_id  = var.public_subnets[each.key]
#   vpc_endpoint_id = aws_vpc_endpoint.s3.id
# }

# resource "aws_vpc_endpoint_route_table_association" "ddb-pl-public" {
#   for_each = toset(var.public_subnets)

#   route_table_id  = var.public_subnets[each.key]
#   vpc_endpoint_id = aws_vpc_endpoint.ddb.id
# }

# resource "aws_vpc_endpoint_route_table_association" "s3-pl-private" {
#   for_each = toset(var.private_subnets)

#   route_table_id  = var.private_subnets[each.key]
#   vpc_endpoint_id = aws_vpc_endpoint.s3.id
# }

# resource "aws_vpc_endpoint_route_table_association" "ddb-pl-private" {
#   for_each = toset(var.private_subnets)

#   route_table_id  = var.private_subnets[each.key]
#   vpc_endpoint_id = aws_vpc_endpoint.ddb.id
# }

/* Interface Endpoints */
resource "aws_vpc_endpoint" "i_endpoints" {
  for_each = toset(var.i_endpoints)

  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.${var.region}.${each.key}"
  vpc_endpoint_type = "Interface"

  security_group_ids = [var.endpoints_sg]
}