# Terraform Bootstrap (`/terraform/bootstrap`)

## Overview
This directory contains the **one-time bootstrap setup** for day-zero infrastructure required before deploying the development environment or running CI/CD pipelines.

> [!IMPORTANT]
> This configuration intentionally uses **local state** because the S3 state bucket and ECR container repository it provisions do not exist yet. Run this once per AWS account before running any commands in `terraform/environments/dev`.

---

## Infrastructure Provisioned
1. **S3 Remote State Bucket** (`ticket-terraform-state-dev-071004`):
   - Server-side AES256 encryption.
   - Bucket versioning enabled.
   - S3 Public Access Block (zero public access).
   - Lifecycle `prevent_destroy = true` safety net.
2. **Amazon ECR Container Repository** (`ticket-worker-dev`):
   - Tag mutability: `MUTABLE`.
   - Automated container image vulnerability scanning on push (`scan_on_push = true`).

---

## Usage Instructions

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

After running `terraform apply`, grab the output values:
- `state_bucket_name`: `ticket-terraform-state-dev-071004`
- `ecr_repository_url`: `<aws_account_id>.dkr.ecr.us-east-1.amazonaws.com/ticket-worker-dev`

Confirm that `state_bucket_name` matches the `backend "s3"` block in [terraform/environments/dev/main.tf](file:///home/admin/prgms/SQS-ECS/terraform/environments/dev/main.tf).
