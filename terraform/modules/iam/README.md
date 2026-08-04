# IAM Terraform Module (`/terraform/modules/iam`)

## Description
Defines AWS IAM roles and policies for ECS execution and task runtime.

## Responsibilities
- Create Task Execution Role (allows ECS agent to pull container images from ECR and log to CloudWatch).
- Create API Task Role (scoped strictly to `sqs:SendMessage` for the target queue).
- Create Worker Task Role (scoped strictly to `sqs:ReceiveMessage`, `sqs:DeleteMessage`, `sqs:GetQueueAttributes`, CloudWatch logs, and RDS access).
- Enforce strict least-privilege principles with no wildcard (`*`) permissions on sensitive resources.
