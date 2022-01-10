variable "resource_prefix" {
  type = string
}

variable "aws_account_id" {
  type        = number
  description = "Account ID in which to create the ALB log bucket"
}

variable "env" {
  type = string
}