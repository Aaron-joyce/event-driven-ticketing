variable "aws_region" {
  description = "AWS region for the state bucket and lock table"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "Globally-unique S3 bucket name for Terraform remote state. Must match the backend block in terraform/environments/*/main.tf"
  type        = string
  default     = "ticket-terraform-state-dev-071004"
}

variable "lock_table_name" {
  description = "DynamoDB table name for Terraform state locking. Must match the backend block in terraform/environments/*/main.tf"
  type        = string
  default     = "ticket-terraform-locks-dev"
}
