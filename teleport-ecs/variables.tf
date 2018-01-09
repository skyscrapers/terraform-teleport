variable "aws_region" {
  default = "eu-west-1"
}

variable "project" {
}

variable "cpu" {
  default = "128"
}

variable "memory" {
  default = "512"
}

variable "memory_reservation" {
  default = "254"
}

variable "teleport_version" {
  description = "Teleport version you want to install"
  default     = "2.3.7"
}

variable "cluster_name" {

}

variable "dynamodb_table" {
  description = "Which dynamodb table does teleport need, teleport will create this table for you. You don't need to define anything in Terraform"
  default     = "main.teleport"
}

variable "dynamodb_region" {
  description = "In which region does the dynamodb table need to be created"
  default     = "eu-west-1"
}

variable "tokens" {
  description = "List of tokens you want to add to the authentication server"
  type        = "list"
  default     = []
}

variable "environment" {

}

variable "vpc_id" {
  description = "VPC ID of where we want to deploy Teleport in"
}

variable "domain_name" {
  description = "Domain name of where we want to reach our cluster. Example can be `company.com`"
}

variable "alb_listener_arn" {
  description = "ARN for the ALB listener, this will be used to add a rule to for the Teleport web part"
}

variable "nlb_arn" {
  description = "ARN for the NLB to create a listener for CLI and tunnel of Tunnelport"
}

variable "nlb_private_arn" {
  description = "ARN for the private NLB to create a listener for the Node auth containers"
}

variable "ecs_cluster" {
  description = "Name of the ECS cluster"
}

variable "desired_count" {
  description = "Desired amount of containers we want to have running of each Teleport component"
  default     = 1
}

variable "create_dns_record" {
  description = "Create DNS records to reach teleport"
  default     = "true"
}
