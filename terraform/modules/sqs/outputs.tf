output "queue_id" {
  value       = aws_sqs_queue.main_queue.id
  description = "Queue ID of the main queue"
}

output "queue_arn" {
  value       = aws_sqs_queue.main_queue.arn
  description = "ARN of the main queue"
}

output "dlq_id" {
  value       = aws_sqs_queue.dlq.id
  description = "Queue ID of the DLQ queue"
}

output "dlq_arn" {
  value       = aws_sqs_queue.dlq.arn
  description = "ARN of the DQL queue"
}
