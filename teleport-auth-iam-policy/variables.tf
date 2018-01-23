variable "role_id" {
  description = "IAM role ID where to attach the Teleport policy."
}

variable "dynamodb_table" {
  description = "Name of the DynamoDB table"
}

variable "dynamodb_region" {
  description = "Region of the DynamoDB table"
  default     = "eu-west-1"
}
