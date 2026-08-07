output "state_bucket_name" {
  description = "S3 bucket name for Terraform remote state"
  value       = aws_s3_bucket.terraform_state.id
}

output "ecr_repository_url" {
  description = "Amazon ECR repository URL for docker push"
  value       = aws_ecr_repository.worker.repository_url
}
