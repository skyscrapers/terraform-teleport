variable "project" {
  type        = string
  description = "A project where this setup belongs to. Only for naming reasons"
}

variable "environment" {
  type        = string
  description = "The environment where this setup belongs to. Only for naming reasons"
}

variable "subnet_id" {
  type        = string
  description = "Subnet id where the EC2 instance will be deployed"
}

variable "key_name" {
  type        = string
  description = "SSH key name for the EC2 instance"
  default     = null
}

variable "r53_zone" {
  type        = string
  description = "The Route53 zone where to add the Teleport DNS record"
}

variable "ami_id" {
  type        = string
  description = "AMI id for the EC2 instance"
  default     = null
}

variable "teleport_version" {
  description = "Teleport version to use. Will be used to search for a compatible AMI if `ami_id` is `null`. If not set, will search for the newest AMI"
  default     = null
  type        = string
}

variable "teleport_cluster_name" {
  type        = string
  description = "Name of the teleport cluster"
  default     = null
}

variable "teleport_dynamodb_table" {
  type        = string
  description = "Name of the DynamoDB table to configure in Teleport"
  default     = null
}

variable "instance_type" {
  type        = string
  description = "Instance type for the EC2 instance"
  default     = "t3.small"
}

variable "instance_ebs_optimized" {
  type        = bool
  description = "If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. See the [EBS Optimized section](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSOptimized.html) of the AWS User Guide for more information"
  default     = null
}

variable "letsencrypt_email" {
  type        = string
  description = "Email to use to register to letsencrypt"
}

variable "teleport_log_output" {
  type        = string
  description = "Teleport logging configuration, possible values are `stdout`, `stderr` and `syslog`"
  default     = "stdout"
}

variable "teleport_log_severity" {
  type        = string
  description = "Teleport logging configuration, possible severity values are `INFO`, `WARN` and `ERROR`"
  default     = "ERROR"
}

variable "teleport_auth_tokens" {
  type        = list(string)
  description = "List of static tokens to configure in the Teleport server. **Note** that these tokens will be added \"as-is\" in the Teleport configuration, so they must be pre-fixed with the token type (e.g. `teleport_auth_tokens = [\"node:sdf34asd7f832efhsdnfsjdfh3i24788923r\"]`). See the official [documentation on static tokens](https://gravitational.com/teleport/docs/admin-guide/#static-tokens) for more info"
  default     = []
}

variable "teleport_session_recording" {
  type        = string
  description = "Setting for configuring session recording in Teleport. Check the [official documentation](https://gravitational.com/teleport/docs/admin-guide/#configuration) for more info"
  default     = "node"
}

variable "allowed_node_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks that are allowed to access the API interface in the `auth` server"
  default     = ["10.0.0.0/8"]
}

variable "allowed_cli_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks that are allowed to access the cli interface of the `proxy` server"
  default     = ["0.0.0.0/0"]
}

variable "allowed_web_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks that are allowed to access the web interface of the `proxy` server"
  default     = ["0.0.0.0/0"]
}

variable "allowed_tunnel_cidr_blocks" {
  type        = list(string)
  description = "CIDR blocks that are allowed to access the reverse tunnel interface of the `proxy` server"
  default     = ["0.0.0.0/0"]
}

variable "root_vl_type" {
  type        = string
  description = "Volume type for the root volume of the EC2 instance. Can be `standard`, `gp2`, or `io1`"
  default     = "gp2"
}

variable "root_vl_size" {
  type        = number
  description = "Volume size for the root volume of the EC2 instance, in gigabytes"
  default     = 16
}

variable "root_vl_delete" {
  type        = bool
  description = "Whether the root volume of the EC2 instance should be destroyed on instance termination"
  default     = true
}

variable "acme_server" {
  type        = string
  description = "ACME server where to point `certbot` on the Teleport server to fetch an SSL certificate. Useful if you want to point to the letsencrypt staging server"
  default     = "https://acme-v02.api.letsencrypt.org/directory"
}

variable "teleport_subdomain" {
  type        = string
  description = "DNS subdomain that will be created for the teleport server"
  default     = "teleport"
}

variable "additional_runcmds" {
  type        = list(string)
  description = "List of additonal commands for cloud-init to run on first boot. See the official [documentation for runcmd](https://cloudinit.readthedocs.io/en/latest/topics/examples.html#run-commands-on-first-boot) for more information"
  default     = null
}
