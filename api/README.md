# API Service (`/api`)

## Description
This directory contains the HTTP API ingestion layer built with **FastAPI**.

## Responsibilities
- Provide REST endpoints (e.g. `POST /tickets`) to ingest ticket purchase requests.
- Validate request payloads using Pydantic models.
- Publish valid ticket requests to the SQS queue using `boto3`.
- Return response confirmation to the client.

## Planned Structure
- `app/main.py`: FastAPI entrypoint and route definitions.
- `app/schemas.py`: Pydantic request/response validation schemas.
- `app/sqs_client.py`: AWS SQS helper module.
- `Dockerfile`: Container image build instructions.
- `tests/`: Unit tests using `pytest` and `moto`/`localstack`.
