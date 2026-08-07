output "state_bucket_name" {
  description = "S3 bucket name — use this in the backend \"s3\" block of other environments"
  value       = aws_s3_bucket.terraform_state.id
}

output "lock_table_name" {
  description = "DynamoDB table name — use this in the backend \"s3\" block of other environments"
  value       = aws_dynamodb_table.terraform_locks.name
}
