variable "aws_region" {
  default = "eu-west-1"
}

variable "project" {
}

variable "cpu" {
  default = "512"
}

variable "memory" {
  default = "1024"
}

variable "memory_reservation" {
  default = "512"
}

variable "teleport_version" {
    default = "3.5.2"
}

variable "cluster_name" {
    
}

variable "dynamodb_table" {
    default = "main.teleport"
}

variable "dynamodb_region" {
    default = "eu-west-1"
}

variable "tokens" {
    
}

variable "environment" {
    
}

variable "vpc_id" {

}

variable "domain_name" {
    
}

variable "alb_listener_arn" {
    
}

variable "nlb_arn" {

}

variable "nlb_private_arn" {
    
}

variable "ecs_cluster" {
  
} 

variable "desired_count" {
  default = 1
}
