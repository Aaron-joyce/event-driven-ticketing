# Worker Service (`/worker`)

## Description
This directory contains the background consumer microservice built with **Python 3.14**, containerized with Docker, and deployed on **AWS ECS Fargate**.

## Responsibilities
- Poll the AWS SQS queue for incoming ticket request messages (`ReceiveMessage`).
- Validate payload JSON structure against the required schema.
- Generate time-ordered native `uuid7()` primary keys.
- Record completed ticket purchase transactions in RDS PostgreSQL.
- Delete messages from SQS (`DeleteMessage`) only after successful database persistence.
- Leverage SQS visibility timeout so un-acknowledged failing messages retry and route to the Dead-Letter Queue (DLQ).

---

## Payload Schema (`POST /tickets`)

The worker expects JSON payloads with the following structure:

```json
{
  "ticket_id": "TICK-VIP-101",
  "ticket_type": "VIP",
  "quantity": 2,
  "buyer_name": "Alice Smith",
  "buyer_email": "alice@example.com"
}
```

### Ingestion Example (`curl`)

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

---

## Directory Structure
- `main.py`: Main SQS long-polling loop (`SQSWorker`) and message handler.
- `db.py`: SQLAlchemy database models (`TicketTransaction`) and dynamic connection string resolution.
- `Dockerfile`: Container image build specification.
- `requirements.txt`: Python package dependencies.
- `tests/test_worker.py`: Unit test suite using `pytest`, `moto` (AWS SQS mock), and in-memory SQLite.
