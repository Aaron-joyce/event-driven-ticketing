# Networking Terraform Module (`/terraform/modules/networking`)

## Description
Provisions the core AWS Virtual Private Cloud (VPC) infrastructure.

## Responsibilities
- Create VPC, Public Subnets, Private Subnets, and Database Subnets across multiple Availability Zones.
- Configure Internet Gateway and NAT Gateway for outbound connectivity from private subnets.
- Define Route Tables and Security Groups adhering to least-privilege principles.
