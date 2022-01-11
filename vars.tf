variable "env" {
  type        = string
  description = "Environment name"
  # validation {
  #   condition = length(regexall("(dev){1}|(stage){1}|(prod){1}(?!.)")) == 1
  #   error_message = "Env identifier should be one of the following: dev, stage, prod"
  # }
  default = "dev"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
  default     = "us-east-1"
}

# variable "default_tags" {
#   type        = map(string)
#   description = "Default tags to apply to all project resources"
# }

variable "domain_name" {
  type        = string
  description = "Project root domain name"
  # validation {
  #   condition = length(regexall("^((?!-))(xn--)?[a-z0-9][a-z0-9-\_]{0,61}[a-z0-9]{0,1}.(xn--)?([a-z0-9\-]{1,61}|[a-z0-9-]{1,30}.[a-z]{2,})$")) == 1
  #   error_message = "Please enter a valid domain name."
  # }
  default = ""
}

# variable "vpc_rfc_range" {
#   type = string
#   description = "A valid RFC CIDR range for env VPC"
#   validation {
#     condition = length(regexall("(192.168)|(10)|(172.16)", var.vpc_rf_range)) > 0
#     error_message = "Must be a valid RFC 1918 range: 10, 192.168, or 172.16"
#   }
#   default = "10"
# }

variable "safe_ips" {
  type        = list(string)
  description = "IP ranges to whitelist for SSH access"
  default     = []
  sensitive = true
}


variable "project_name" {
  type        = string
  description = "Project name"
  validation {
    condition     = length(regexall("([A-za-z0-9-])+", var.project_name)) > 0
    error_message = "Project name should be alphanumeric and optionally include hyphens."
  }
}

variable "aws_account_id" {
  type        = number
  description = "AWS account id"
  validation {
    condition     = length(regexall("([0-9])+", var.aws_account_id)) > 0
    error_message = "AWS account ID must be a 12 digit number."
  }
  sensitive = true
}

variable "vpc_cidr" {
  type        = map(string)
  description = "CIDR block range for environment VPCs"
  default = {
    dev   = "10.0.0.0/16"
    stage = "10.10.0.0/16"
    prod  = "10.20.0.0/16"
  }
}

variable "max_capacity" {
  type = number
}

variable "min_capacity" {
  type = number
}