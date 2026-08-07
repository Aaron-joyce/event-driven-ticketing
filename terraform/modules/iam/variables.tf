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

}

variable "github_owner_id" {
  type        = string
  description = "GitHub numeric owner ID (immutable). Get via: gh api /users/OWNER --jq .id"
  default     = "30692913"
}

variable "github_repo_id" {
  type        = string
  description = "GitHub numeric repository ID (immutable). Get via: gh api /repos/OWNER/REPO --jq .id"
  default     = "1322898996"
}
