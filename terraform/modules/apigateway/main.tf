resource "aws_api_gateway_rest_api" "ticket_api" {
  name        = "ticket-api-${var.environment}"
  description = "API Gateway for enqueuing ticket purchase requests directly into SQS"

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}

resource "aws_api_gateway_resource" "tickets" {
  rest_api_id = aws_api_gateway_rest_api.ticket_api.id
  parent_id   = aws_api_gateway_rest_api.ticket_api.root_resource_id
  path_part   = "tickets"
}

resource "aws_api_gateway_method" "post_tickets" {
  rest_api_id   = aws_api_gateway_rest_api.ticket_api.id
  resource_id   = aws_api_gateway_resource.tickets.id
  http_method   = "POST"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "sqs_integration" {
  rest_api_id             = aws_api_gateway_rest_api.ticket_api.id
  resource_id             = aws_api_gateway_resource.tickets.id
  http_method             = aws_api_gateway_method.post_tickets.http_method
  type                    = "AWS"
  integration_http_method = "POST"
  uri                     = "arn:aws:apigateway:${var.aws_region}:sqs:path/${var.account_id}/${var.sqs_queue_name}"
  credentials             = var.api_gateway_role_arn

  request_parameters = {
    "integration.request.header.Content-Type" = "'application/x-www-form-urlencoded'"
  }

  request_templates = {
    "application/json" = "Action=SendMessage&MessageBody=$util.urlEncode($input.body)"
  }
}

resource "aws_api_gateway_method_response" "response_202" {
  rest_api_id = aws_api_gateway_rest_api.ticket_api.id
  resource_id = aws_api_gateway_resource.tickets.id
  http_method = aws_api_gateway_method.post_tickets.http_method
  status_code = "202"

  response_models = {
    "application/json" = "Empty"
  }
}

resource "aws_api_gateway_integration_response" "sqs_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.ticket_api.id
  resource_id = aws_api_gateway_resource.tickets.id
  http_method = aws_api_gateway_method.post_tickets.http_method
  status_code = aws_api_gateway_method_response.response_202.status_code

  response_templates = {
    "application/json" = jsonencode({
      status  = "accepted"
      message = "Ticket request enqueued successfully"
    })
  }

  depends_on = [aws_api_gateway_integration.sqs_integration]
}

resource "aws_api_gateway_deployment" "deployment" {
  rest_api_id = aws_api_gateway_rest_api.ticket_api.id

  depends_on = [aws_api_gateway_integration.sqs_integration]

  triggers = {
    redeployment = sha1(jsonencode(aws_api_gateway_integration.sqs_integration))
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_api_gateway_stage" "stage" {
  deployment_id = aws_api_gateway_deployment.deployment.id
  rest_api_id   = aws_api_gateway_rest_api.ticket_api.id
  stage_name    = var.environment
}
