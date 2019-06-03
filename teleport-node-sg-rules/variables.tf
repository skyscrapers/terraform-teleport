variable "teleport_proxy_sg_id" {
  type        = string
  description = "Security group id of the `proxy` server."
}

variable "teleport_node_sg_id" {
  type        = string
  description = "Security group id of the `node` server."
}

variable "teleport_auth_sg_id" {
  type        = string
  description = "Security group id of the `auth` server."
}
