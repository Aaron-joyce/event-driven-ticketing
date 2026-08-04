# API Gateway Terraform Module (`/terraform/modules/apigateway`)

## Description
Provisions AWS API Gateway with direct AWS Service Integration to SQS.

## Responsibilities
- Create API Gateway (REST API or HTTP API).
- Define `/tickets` resource and `POST` method.
- Configure AWS Service Integration targeting `sqs:SendMessage` on the primary ticket queue.
- Define IAM Execution Role allowing API Gateway to put messages into SQS.
- Map request JSON body directly to SQS `SendMessage` action.
