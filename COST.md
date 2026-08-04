# AWS Cost Estimation & Resource Management

> [!WARNING]
> Running this infrastructure in an AWS account will incur real AWS charges. Ensure you destroy resources when testing is completed.

## Resource Cost Breakdown (Estimated Dev Profile)

| Resource | Service / Specs | Estimated Cost |
| :--- | :--- | :--- |
| **NAT Gateway** | 1x VPC NAT Gateway + Data Transfer | ~$0.045 / hour (~$32 / month baseline) |
| **RDS PostgreSQL** | `db.t4g.micro` (Single-AZ, 20GB storage) | ~$0.016 / hour (~$12 / month) |
| **ECS Fargate** | 2 Tasks (API & Worker: 0.25 vCPU, 0.5GB RAM) | ~$0.012 / hour (~$9 / month) |
| **Application Load Balancer** | 1x ALB + LCU usage | ~$0.0225 / hour (~$16 / month) |
| **SQS, ECR, CloudWatch** | Standard tier pay-per-use | Near-zero for demo scale (< $1) |

---

## Resource Teardown Command

To prevent unintended charges, execute the following command when finished:

```bash
cd terraform/environments/dev
terraform destroy -auto-approve
```
