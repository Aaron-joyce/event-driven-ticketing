variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "ecr_repository_name" {
  description = "ECR repository name for worker container images (must match the bootstrap module's output)"
  type        = string
  default     = "ticket-worker-dev"
}

variable "worker_image_tag" {
  description = "Docker image tag to deploy. CI passes the commit SHA on every run; defaults to 'latest' for local testing."
  type        = string
  default     = "latest"
}
