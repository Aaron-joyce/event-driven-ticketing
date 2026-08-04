# Dev Environment Terraform Configuration (`/terraform/environments/dev`)

## Description
Main entrypoint for provisioning the development infrastructure environment by composing the root modules.

## Responsibilities
- Define S3 backend configuration and DynamoDB state lock table reference.
- Instantiate modules: `networking`, `sqs`, `ecs`, `rds`, and `iam`.
- Provide `terraform.tfvars` definitions for dev environment parameters.
