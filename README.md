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
├── worker/                 # Python background worker service (ECS Fargate)
│   ├── db.py               # Database connections and SQLAlchemy models
│   ├── main.py             # SQS polling loop and transaction handler
│   ├── Dockerfile          # Fargate container image specification
│   ├── requirements.txt    # Worker service dependencies
│   └── tests/              # Pytest unit tests using moto & SQLite
├── terraform/
│   ├── modules/
│   │   ├── apigateway/     # API Gateway direct SQS integration module
│   │   ├── ecs/            # ECS Fargate worker & scaling module
│   │   ├── iam/            # Scoped IAM task/execution roles module
│   │   ├── networking/     # VPC, Subnets, NAT Gateway module
│   │   ├── rds/            # PostgreSQL RDS module
│   │   └── sqs/            # SQS & DLQ queue module
│   └── environments/
│       └── dev/            # Development environment deployment
├── pytest.ini              # Pytest configuration
├── COST.md                 # AWS Cost estimations & destroy instructions
└── README.md               # Project documentation
```

---

## Design Decisions

### Application & Architecture Layer
- **Zero-Compute Ingestion (API Gateway -> SQS)**: Uses AWS Service Integration on API Gateway (`POST /tickets` -> `sqs:SendMessage`). Eliminates API container overhead, ensuring 100% serverless HTTP ingestion and zero cold starts.
- **Dedicated Python Consumer Microservice**: Runs continuously on AWS ECS Fargate, polling SQS via long polling (`WaitTimeSeconds=10`) to consume and process ticket transactions asynchronously.
- **SQLAlchemy ORM & Native UUIDv7**: Manages PostgreSQL database persistence. Uses `uuid7()` for primary key generation to ensure sequential, time-sortable database index performance.
- **At-Least-Once Delivery & Failure Handling**: SQS messages are only deleted (`sqs:delete_message`) **after** `db.commit()` succeeds. On failure, `db.rollback()` executes, skipping message deletion to allow SQS visibility timeout expiration and retry/DLQ routing.

### Infrastructure & Security Layer
*(To be populated in Phase 3)*

### CI/CD & Operations Layer
*(To be populated in Phase 4)*

---

## Local Development & Testing

Run unit tests locally against AWS mocks (`moto`) and in-memory SQLite:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r worker/requirements.txt
pytest
```
