variable "environment" {
  type    = string
  default = "dev"
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "sqs_queue_arn" {
  type = string
}

variable "sqs_queue_name" {
  type = string
}

variable "account_id" {
  type = string
}

variable "api_gateway_role_arn" {
  type = string
}
