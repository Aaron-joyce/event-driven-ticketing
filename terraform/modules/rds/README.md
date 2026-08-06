# RDS Terraform Module (`/terraform/modules/rds`)

## Description
Provisions the relational database layer and secret management infrastructure.

## Responsibilities
- Create Single-AZ PostgreSQL instance (`db.t4g.micro`) within private database subnets.
- Generate a 16-character secure database password using `random_password`.
- Provision **AWS Secrets Manager** secret (`aws_secretsmanager_secret`) to store database credentials securely without hardcoding in Git or `.tfvars`.
- Configure DB Subnet Group and DB Security Group.
- Restrict inbound traffic strictly to port 5432 ingress from the worker ECS task security group.
