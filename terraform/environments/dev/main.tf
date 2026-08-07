terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }

  backend "s3" {
    bucket       = "ticket-terraform-state-dev-071004"
    key          = "dev/terraform.tfstate"
    region       = "us-east-1"
    encrypt      = true
    use_lockfile = true
  }
}

provider "aws" {
  region = var.aws_region
}

data "aws_caller_identity" "current" {}

module "networking" {
  source      = "../../modules/networking"
  environment = var.environment
}

module "sqs" {
  source      = "../../modules/sqs"
  environment = var.environment
}

module "rds" {
  source                   = "../../modules/rds"
  environment              = var.environment
  vpc_id                   = module.networking.vpc_id
  database_subnet_ids      = module.networking.database_subnet_ids
  worker_security_group_id = module.ecs.worker_security_group_id
}

module "iam" {
  source        = "../../modules/iam"
  environment   = var.environment
  sqs_queue_arn = module.sqs.queue_arn
  db_secret_arn = module.rds.db_secret_arn
}

module "apigateway" {
  source               = "../../modules/apigateway"
  environment          = var.environment
  aws_region           = var.aws_region
  sqs_queue_arn        = module.sqs.queue_arn
  sqs_queue_name       = element(split("/", module.sqs.queue_id), length(split("/", module.sqs.queue_id)) - 1)
  account_id           = data.aws_caller_identity.current.account_id
  api_gateway_role_arn = module.iam.api_gateway_role_arn
}

module "ecs" {
  source             = "../../modules/ecs"
  environment        = var.environment
  aws_region         = var.aws_region
  vpc_id             = module.networking.vpc_id
  private_subnet_ids = module.networking.private_subnet_ids
  execution_role_arn = module.iam.ecs_execution_role_arn
  task_role_arn      = module.iam.ecs_task_role_arn
  sqs_queue_url      = module.sqs.queue_id
  sqs_queue_arn      = module.sqs.queue_arn
  db_secret_arn      = module.rds.db_secret_arn
  db_host            = module.rds.endpoint
  db_name            = module.rds.db_name
}
