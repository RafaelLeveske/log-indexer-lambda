variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "domain_name" {
  description = "OpenSearch domain name"
  type        = string
  default     = "log-observability"
}

variable "engine_version" {
  description = "OpenSearch engine version"
  type        = string
  default     = "OpenSearch_2.11"
}

variable "master_user" {
  description = "Master user for OpenSearch"
  type        = string
  default     = "admin"
}

variable "ssm_password_parameter_name" {
  description = "SSM Parameter name for master password"
  type        = string
}

variable "index_name" {
  description = "Index name to store logs"
  type        = string
  default     = "application-logs"
}