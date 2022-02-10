variable "region" {
  type = string
}

variable "vpc_cidr" {
  type        = string
  description = "CIDR block range for environment VPC"
}

variable "azs" {
  type        = list(string)
  description = "Available AZs for the given region"
}

variable "safe_ips" {
  type = list(string)
}

variable "resource_prefix" {
  type = string
}
