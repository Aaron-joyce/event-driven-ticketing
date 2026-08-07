# terraform/bootstrap
#
# One-time setup for the remote state backend (S3 + DynamoDB) used by
# every other Terraform config in this repo (terraform/environments/*).
#
# This config intentionally uses LOCAL state, not the S3 backend it creates —
# it can't point at a backend that doesn't exist yet. Run this once per AWS
# account, then never touch it again unless you're changing backend config.
#
# Usage:
#   cd terraform/bootstrap
#   terraform init
#   terraform apply
#
# Then grab the bucket/table names from the outputs and confirm they match
# the backend "s3" block in terraform/environments/dev/main.tf.

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  # Deliberately no backend block here — local state only, by design.
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = var.state_bucket_name

  # Safety net: prevents `terraform destroy` from accidentally deleting
  # the bucket that holds every other environment's state.
  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state" {
  bucket = aws_s3_bucket.terraform_state.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
