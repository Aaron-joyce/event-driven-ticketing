# ECS Fargate Terraform Module (`/terraform/modules/ecs`)

## Description
Provisions Elastic Container Service (ECS) Fargate workload infrastructure.

## Responsibilities
- Create ECS Cluster.
- Define Task Definitions and ECS Services for API and Worker containers.
- Configure Application Auto Scaling based on SQS queue depth (CloudWatch metric `ApproximateNumberOfMessagesVisible`).
- Provision Application Load Balancer (ALB) target groups and listeners for the API service.
