variable "project" {}

variable "environment" {}

variable "subnet_id" {}

variable "key_name" {}

variable "ami" {}

variable "vpc_id" {}

variable "r53_zone" {}

variable "teleport_cluster_name" {
  default = ""
}

variable "teleport_dynamodb_table" {
  default = ""
}

variable "instance_type" {
  default = "t2.small"
}

variable "letsencrypt_email" {
  default = "letsencrypt@skyscrapers.eu"
}

variable "teleport_log_output" {
  default = "stdout"
}

variable "teleport_log_severity" {
  default = "ERROR"
}

variable "teleport_auth_tokens" {
  default = []
}

variable "teleport_session_recording" {
  default = "node"
}

variable "allowed_node_cidr_blocks" {
  default = ["10.0.0.0/8"]
}

variable "allowed_cli_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "allowed_web_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "allowed_tunnel_cidr_blocks" {
  default = ["0.0.0.0/0"]
}

variable "root_vl_type" {
  default = "gp2"
}

variable "root_vl_size" {
  default = "16"
}

variable "root_vl_delete" {
  default = "true"
}

variable "acme_server" {
  default = "https://acme-v01.api.letsencrypt.org/directory"
}

variable "teleport_subdomain" {
  default = "teleport"
}
