variable "environment" {
  type    = string
  default = "dev"
}

variable "sqs_queue_arn" {
  type = string
}

variable "db_secret_arn" {
  type = string
}
