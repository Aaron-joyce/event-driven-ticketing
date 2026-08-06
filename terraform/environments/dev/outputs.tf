output "api_endpoint" {
  value = module.apigateway.api_endpoint
}

output "sqs_queue_url" {
  value = module.sqs.queue_id
}

output "rds_endpoint" {
  value = module.rds.endpoint
}

output "ecs_cluster_name" {
  value = module.ecs.cluster_name
}
