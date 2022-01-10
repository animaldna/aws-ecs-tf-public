variable "vpc_id" {
  type = string
}

variable "resource_prefix" {
  type = string
}

variable "env" {
  type = string
}

variable "aws_account_id" {
  type = number
}

variable "public_subnets" {
  type = list(string)
}

variable "security_groups" {
  type = list(string)
}

variable "acm_cert" {
  type = string
}