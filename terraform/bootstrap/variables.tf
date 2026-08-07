variable "aws_region" {
  description = "AWS region for bootstrap infrastructure"
  type        = string
  default     = "us-east-1"
}

variable "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  type        = string
  default     = "ticket-terraform-state-dev-071004"
}

variable "ecr_repository_name" {
  description = "Amazon ECR repository name for worker container images"
  type        = string
  default     = "ticket-worker-dev"
}
