variable "vpc_id" {
  type        = string
  description = ""
}

variable "region" {
  type        = string
  description = ""
}

variable "endpoints_sg" {
  type        = string
  description = ""
}

variable "i_endpoints" {
  type        = list(string)
  description = "List of required interface endpoints by their service names"
  default     = ["ecr.api", "ecr.dkr", "logs", "elasticloadbalancing"]
}

# variable "public_subnets" {
#   type = list(string)
# }

# variable "private_subnets" {
#   type = list(string)
# }

variable "private_rts" {
  type = list(string)
}

variable "public_rts" {
  type = list(string)
}