variable "environment" {
  type        = string
  default     = "dev"
  description = "Deployment Environment Name"
}

variable "queue_name" {
  type        = string
  default     = "ticket-queue"
  description = "Base Name for the SQS queue"
}

variable "visibility_timeout_seconds" {
  type        = number
  default     = 30
  description = "Visibility timeout for message in seconds"
}

variable "max_receive_count" {
  type        = number
  default     = 3
  description = "Number of times a message can be received before routing to DLQ"
}
