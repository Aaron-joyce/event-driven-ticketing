variable "environment" {
  type    = string
  default = "dev"
}

variable "vpc_id" {
  type = string
}

variable "database_subnet_ids" {
  type = list(string)
}

variable "worker_security_group_id" {
  type = string
}

variable "db_name" {
  type    = string
  default = "ticket_db"
}

variable "db_username" {
  type    = string
  default = "postgres"
}
