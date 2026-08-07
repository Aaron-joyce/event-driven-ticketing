# Remote State Backend Module (`/terraform/modules/backend`)

## Description
Provisions S3 state bucket and DynamoDB lock table for Terraform remote state storage.

## Responsibilities
- S3 Bucket with versioning enabled and server-side AES256 encryption.
- Public access block enforcing zero public visibility on state files.
- DynamoDB state locking table (`PAY_PER_REQUEST`) with `LockID` primary key.
