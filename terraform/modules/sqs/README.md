# SQS Terraform Module (`/terraform/modules/sqs`)

## Description
Provisions Simple Queue Service (SQS) infrastructure for event decoupling.

## Responsibilities
- Create the primary standard SQS message queue.
- Create and attach a Dead-Letter Queue (DLQ) with redrive policy (`maxReceiveCount`).
- Configure queue visibility timeout and retention policies.
