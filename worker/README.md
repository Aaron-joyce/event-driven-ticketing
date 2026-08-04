# Worker Service (`/worker`)

## Description
This directory contains the background consumer service built with **Python**, designed to run as an **ECS Fargate task**.

## Responsibilities
- Poll the AWS SQS queue for incoming ticket request messages (`ReceiveMessage`).
- Validate payload integrity and business rules.
- Simulate ticket allocation / order fulfillment logic.
- Record transactions in the RDS PostgreSQL database.
- Explicitly delete messages from SQS upon successful processing (`DeleteMessage`).
- Handle retries gracefully so failing messages naturally route to the Dead-Letter Queue (DLQ).

## Planned Structure
- `worker.py`: Main polling loop and message handler logic.
- `db.py`: Database connection and transaction persistence.
- `Dockerfile`: Container image specification.
- `tests/`: Unit tests for polling and processing logic using `pytest` and mocks.
