# Event-Driven AWS Backend Pipeline (SQS-ECS)

An asynchronous, event-driven ticket processing pipeline built with **AWS API Gateway**, **Amazon SQS**, **AWS ECS Fargate**, and **Amazon RDS (PostgreSQL)**, fully provisioned via **Terraform** with **GitHub Actions CI/CD**.

---

## Architecture Overview

```mermaid
flowchart LR
    Client([Client / Postman]) -->|1. HTTP POST /tickets| APIGW[AWS API Gateway]
    subgraph VPC [AWS VPC - Dev Environment]
        subgraph PublicSubnets [Public Subnets]
            NAT[NAT Gateway]
        end
        
        subgraph PrivateSubnets [Private Subnets]
            Worker[Worker Container - ECS Fargate]
            SQS[(SQS Ticket Queue)]
            DLQ[(SQS Dead-Letter Queue)]
            RDS[(RDS PostgreSQL)]
        end
    end
    
    APIGW -->|2. Direct AWS Integration SendMessage| SQS
    SQS -->|3. Poll & Consume Message| Worker
    Worker -->|4. Write Transaction Record| RDS
    SQS -.->|Failed retries > 3| DLQ
```

---

## Directory Structure

```
.
├── .github/
│   └── workflows/          # GitHub Actions CI/CD workflows
│       ├── pr.yml          # Pull request lint, secret scan, test, and tf validate
│       └── deploy.yml      # Main merge build ECR image and terraform apply
├── worker/                 # Python background worker service (ECS Fargate)
│   ├── db.py               # Database connections and SQLAlchemy models
│   ├── main.py             # SQS polling loop and transaction handler
│   ├── Dockerfile          # Fargate container image specification
│   ├── requirements.txt    # Worker service dependencies
│   └── tests/              # Pytest unit tests using moto & SQLite
├── terraform/
│   ├── bootstrap/          # One-time day-zero setup (S3 state bucket & ECR repo)
│   ├── modules/
│   │   ├── apigateway/     # API Gateway direct SQS integration module
│   │   ├── ecs/            # ECS Fargate worker & scaling module
│   │   ├── iam/            # Scoped IAM task/execution/OIDC roles module
│   │   ├── networking/     # VPC, Subnets, NAT Gateway module
│   │   ├── rds/            # PostgreSQL RDS module
│   │   └── sqs/            # SQS & DLQ queue module
│   └── environments/
│       └── dev/            # Development environment deployment
├── pyproject.toml          # Ruff linter configuration
├── pytest.ini              # Pytest configuration
├── COST.md                 # AWS Cost estimations & destroy instructions
└── README.md               # Project documentation
```

---

## Payload Schema & Ingestion

### Request Payload Schema (`POST /tickets`)

The system accepts JSON payloads matching the following schema:

| Field | Type | Description | Example |
| :--- | :--- | :--- | :--- |
| `ticket_id` | String | Unique ticket identifier | `"TICK-VIP-101"` |
| `ticket_type` | String | Ticket tier (e.g. VIP, General, EarlyBird) | `"VIP"` |
| `quantity` | Integer | Number of tickets requested | `2` |
| `buyer_name` | String | Full name of ticket buyer | `"Alice Smith"` |
| `buyer_email` | String | Valid email address of buyer | `"alice@example.com"` |

### Example Ingestion Request (`curl`)

```bash
curl -X POST https://<api-id>.execute-api.us-east-1.amazonaws.com/dev/tickets \
     -H "Content-Type: application/json" \
     -d '{
       "ticket_id": "TICK-VIP-101",
       "ticket_type": "VIP",
       "quantity": 2,
       "buyer_name": "Alice Smith",
       "buyer_email": "alice@example.com"
     }'
```

**Expected Response**: `202 Accepted`
```json
{
  "status": "accepted",
  "message": "Ticket request enqueued successfully"
}
```

---

## Design Decisions

### Application & Architecture Layer
- **Zero-Compute Ingestion (API Gateway -> SQS)**: Uses AWS Service Integration on API Gateway (`POST /tickets` -> `sqs:SendMessage`). Eliminates API container compute overhead, ensuring 100% serverless HTTP ingestion and zero cold starts.
- **Dedicated Python Consumer Microservice**: Runs continuously on AWS ECS Fargate, polling SQS via long polling (`WaitTimeSeconds=10`) to consume and process ticket transactions asynchronously.
- **SQLAlchemy ORM & Native UUIDv7**: Manages PostgreSQL database persistence. Uses `uuid7()` for primary key generation to ensure sequential, time-sortable database index performance.
- **At-Least-Once Delivery & Failure Handling**: SQS messages are only deleted (`sqs:delete_message`) **after** `db.commit()` succeeds. On failure, `db.rollback()` executes, skipping message deletion to allow SQS visibility timeout expiration and retry/DLQ routing.

### Infrastructure & Security Layer
- **Multi-AZ VPC Isolation**: Provisions 2 Public Subnets, 2 Private Application Subnets, and 2 Private Database Subnets across separate Availability Zones. NAT Gateway routes outbound traffic for private worker tasks.
- **Least-Privilege Security Groups**: No `0.0.0.0/0` ingress on internal components. RDS PostgreSQL accepts traffic *only* on port 5432 from the ECS Worker Security Group.
- **AWS Secrets Manager Integration**: Generates a 16-character secure database password via `random_password` and stores it in AWS Secrets Manager. ECS Fargate container automatically retrieves `DB_PASSWORD` at startup using the `secrets` container definition block.
- **Auto-Scaling on Queue Depth**: CloudWatch metric alarm on `ApproximateNumberOfMessagesVisible > 10` triggers Application Auto Scaling step policies to dynamically scale worker container tasks.
- **S3 Native State Locking**: Configures S3 backend (`ticket-terraform-state-dev-071004`) using Terraform's native S3 state locking (`use_lockfile = true` via S3 conditional writes) to prevent concurrent deployment state collisions without requiring DynamoDB tables.

### CI/CD & Operations Layer
- **Keyless AWS OIDC Authentication**: Uses IAM OIDC Identity Federation (`sts:AssumeRoleWithWebIdentity`) scoped to repository subjects. Supports both standard repository strings (`repo:Aaron-joyce/event-driven-ticketing:*`) and GitHub's immutable-ID subject claims (`repo:Aaron-joyce@30692913/event-driven-ticketing@1322898996:*`) to prevent spoofing if repositories are renamed.
- **Scoped Least-Privilege Deployment Policy**: Replaced broad AWS `PowerUserAccess` with a custom hand-written CI/CD policy (`github-actions-deploy-policy-dev`) restricted strictly to the resource actions managed by Terraform.
- **Immutable Image Tagging & ECS Task Replacement**: Container images pushed to Amazon ECR are tagged with commit SHAs alongside `latest`. Updating the task definition container image reference triggers a controlled ECS Fargate rolling replacement (`-/+` destroy-then-create of Task Definition revisions and task instances).
- **Automated PR Gateways (`pr.yml`)**: On every Pull Request to `main`:
  - **TruffleHog**: Automated secret scanning to prevent accidental API keys or secrets from reaching Git.
  - **Ruff**: Fast Python linting and code formatting checks.
  - **Pytest**: Unit testing worker processing logic against `moto` AWS mocks and SQLite.
  - **Terraform Validation**: Enforces `terraform fmt -check` and `terraform validate`.
- **Automated Deployment Pipeline (`deploy.yml`)**: On merge to `main`, builds container image, pushes to Amazon ECR, and executes `terraform apply`.

---

## Setup & Teardown

### Step 1: One-Time Day-Zero Bootstrap (`terraform/bootstrap`)

> [!IMPORTANT]
> The S3 remote state bucket and ECR repository must be bootstrapped once per AWS account before running environment deployments.

```bash
cd terraform/bootstrap
terraform init
terraform apply
```

Note the outputs:
- `state_bucket_name`: `ticket-terraform-state-dev-071004`
- `ecr_repository_url`: `<account_id>.dkr.ecr.us-east-1.amazonaws.com/ticket-worker-dev`

### Step 2: Local Testing (Unit Tests & Linting)
```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r worker/requirements.txt ruff pytest
ruff check .
pytest
```

### Step 3: Development Environment Deployment (`terraform/environments/dev`)
```bash
cd terraform/environments/dev
terraform init
terraform plan
terraform apply
```

### Infrastructure Teardown
To destroy all provisioned AWS environment resources and avoid unnecessary charges:
```bash
cd terraform/environments/dev
terraform destroy -auto-approve
```
