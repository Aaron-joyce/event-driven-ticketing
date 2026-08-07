variable "environment" {
  type    = string
  default = "dev"
}

variable "state_bucket_name" {
  type        = string
  default     = "ticket-terraform-state-dev"
  description = "Name of the S3 bucket for Terraform remote state"
}

variable "lock_table_name" {
  type        = string
  default     = "ticket-terraform-locks-dev"
  description = "Name of the DynamoDB table for Terraform state locking"
}
