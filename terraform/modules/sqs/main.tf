resource "aws_sqs_queue" "dlq" {
  name                      = "${var.queue_name}-dlq-${var.environment}"
  message_retention_seconds = 1209600

  tags = {
    Name        = "${var.queue_name}-dlq-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_sqs_queue" "main_queue" {
  name                      = "${var.queue_name}-${var.environment}"
  message_retention_seconds = 345600

  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = var.max_receive_count
  })

  tags = {
    Name        = "${var.queue_name}-${var.environment}"
    Environment = var.environment
  }
}
