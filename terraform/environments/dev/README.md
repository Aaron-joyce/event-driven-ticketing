# Dev Environment Terraform Configuration (`/terraform/environments/dev`)

## Description
Main entrypoint for provisioning the development infrastructure environment by composing root modules.

## Prerequisites
Before running `terraform init` in this directory, the day-zero bootstrap infrastructure must be provisioned once per account:
```bash
cd terraform/bootstrap
terraform init
terraform apply
```

## Responsibilities
- S3 Remote State Backend (`ticket-terraform-state-dev-071004`) using S3 native state locking (`use_lockfile = true` via S3 conditional writes).
- Instantiate modules: `networking`, `sqs`, `apigateway`, `rds`, `iam`, and `ecs`.
- Provide `terraform.tfvars` definitions for dev environment parameters.
