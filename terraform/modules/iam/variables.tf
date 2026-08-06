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

variable "github_repo" {
  type        = string
  default     = "Aaron-joyce/event-driven-ticketing"
  description = "GitHub repository string formatted as 'username/repo-name'"
}
