variable "project" {
  description = "A project where this setup belongs to. Only for naming reasons."
}

variable "environment" {
  description = "The environment where this setup belongs to. Only for naming reasons."
}

variable "subnet_id" {
  description = "Subnet id where the EC2 instance will be deployed."
}

variable "key_name" {
  description = "SSH key name for the EC2 instance."
}

variable "ami_id" {
  description = "AMI id for the EC2 instance."
}

variable "r53_zone" {
  description = "The Route53 zone where to add the Teleport DNS record."
}

variable "teleport_cluster_name" {
  description = "Name of the teleport cluster."
  default     = ""
}

variable "teleport_dynamodb_table" {
  description = "Name of the DynamoDB table to configure in Teleport."
  default     = ""
}

variable "instance_type" {
  description = "Instance type for the EC2 instance."
  default     = "t2.small"
}

variable "letsencrypt_email" {
  description = "Email to use to register to letsencrypt."
  default     = "letsencrypt@skyscrapers.eu"
}

variable "teleport_log_output" {
  description = "Teleport logging configuration, possible values are `stdout`, `stderr` and `syslog`."
  default     = "stdout"
}

variable "teleport_log_severity" {
  description = "Teleport logging configuration, possible severity values are `INFO`, `WARN` and `ERROR`."
  default     = "ERROR"
}

variable "teleport_auth_tokens" {
  description = "List of static tokens to configure in the Teleport server. See the official documentation on static tokens [here](https://gravitational.com/teleport/docs/2.3/admin-guide/#static-tokens)."
  default     = []
}

variable "teleport_session_recording" {
  description = "Setting for configuring session recording in Teleport. Check the [official documentation](https://gravitational.com/teleport/docs/2.4/admin-guide/#configuration) for more info."
  default     = "node"
}

variable "allowed_node_cidr_blocks" {
  description = "CIDR blocks that are allowed to access the API interface in the `auth` server."
  default     = ["10.0.0.0/8"]
}

variable "allowed_cli_cidr_blocks" {
  description = "CIDR blocks that are allowed to access the cli interface of the `proxy` server."
  default     = ["0.0.0.0/0"]
}

variable "allowed_web_cidr_blocks" {
  description = "CIDR blocks that are allowed to access the web interface of the `proxy` server."
  default     = ["0.0.0.0/0"]
}

variable "allowed_tunnel_cidr_blocks" {
  description = "CIDR blocks that are allowed to access the reverse tunnel interface of the `proxy` server."
  default     = ["0.0.0.0/0"]
}

variable "root_vl_type" {
  description = "Volume type for the root volume of the EC2 instance. Can be `standard`, `gp2`, or `io1`."
  default     = "gp2"
}

variable "root_vl_size" {
  description = "Volume size for the root volume of the EC2 instance, in gigabytes."
  default     = 16
}

variable "root_vl_delete" {
  description = "Whether the root volume of the EC2 instance should be destroyed on instance termination."
  default     = "true"
}

variable "acme_server" {
  description = "ACME server where to point `certbot` on the Teleport server to fetch an SSL certificate. Useful if you want to point to the letsencrypt staging server."
  default     = "https://acme-v01.api.letsencrypt.org/directory"
}

variable "teleport_subdomain" {
  description = "DNS subdomain that will be created for the teleport server."
  default     = "teleport"
}
