variable "resource_prefix" {
  type = string
}

variable "security_groups" {
  type = list(string)
}

variable "env" {
  type = string
}

variable "alb_target_group" {
  type = string
}

variable "public_subnets" {
  type = list(string)
}

variable "repo_name" {
  type        = string
  description = "Repo to pull image from"
  default     = ""
}

variable "region" {
  type        = string
  description = "Current AWS region"
  default     = "us-east-1"
}