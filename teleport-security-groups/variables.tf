variable "vpc_id" {
  description = "VPC ID where to deploy the security groups"
}

variable "cidr_blocks" {
  description = "CIDR blocks from where to allow connections to the Teleport cluster."
  default     = ["0.0.0.0/0"]
}
