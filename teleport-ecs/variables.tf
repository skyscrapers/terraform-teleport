variable "aws_region" {
  description = "AWS region we are deploying in"
  default = "eu-west-1"
}

variable "project" {
  description = "Project where this node belongs to, will be the second part of the node name. Defaults to ''"
  default     = ""
}

variable "cpu" {
  description = "The number of CPU units used by the task. It can be expressed as an integer using CPU units, for example 1024, or as a string using vCPUs, for example 1 vCPU or 1 vcpu, in a task definition but will be converted to an integer indicating the CPU units when the task definition is registered."
  default     = "128"
}

variable "memory" {
  description = "The amount of memory (in MiB) used by the task. It can be expressed as an integer using MiB, for example 1024, or as a string using GB, for example 1GB or 1 GB, in a task definition but will be converted to an integer indicating the MiB when the task definition is registered."
  default     = "512"
}

variable "memory_reservation" {
  description = "The soft limit (in MiB) of memory to reserve for the container. When system memory is under contention, Docker attempts to keep the container memory to this soft limit; however, your container can consume more memory when it needs to, up to either the hard limit specified with the memory parameter (if applicable), or all of the available memory on the container instance, whichever comes first."
  default     = "254"
}

variable "teleport_version" {
  description = "Teleport version you want to install"
  default     = "2.3.7"
}

variable "cluster_name" {
  description = "Name of the cluster"
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
  description = "Environment where this node belongs to, will be the third part of the node name. Defaults to ''"
  default     = ""
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
  description = "ARN for the NLB to create a listener for CLI and tunnel"
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
