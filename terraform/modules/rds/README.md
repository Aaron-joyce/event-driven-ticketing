# RDS Terraform Module (`/terraform/modules/rds`)

## Description
Provisions the relational database layer.

## Responsibilities
- Create Single-AZ PostgreSQL instance (`db.t4g.micro`) within private database subnets.
- Configure DB Subnet Group, Parameter Group, and DB Security Group.
- Restrict inbound traffic strictly to worker ECS tasks.
