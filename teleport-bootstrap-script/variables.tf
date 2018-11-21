variable "auth_server" {
  description = "Auth server that this node will connect to, including the port number"
}

variable "auth_token" {
  description = "Auth token that this node will present to the auth server."
}

variable "function" {
  description = "Function that this node performs, will be the first part of the node name."
}

variable "project" {
  description = "Project where this node belongs to, will be the second part of the node name."
  default     = ""
}

variable "environment" {
  description = "Environment where this node belongs to, will be the third part of the node name."
  default     = ""
}

variable "include_instance_id" {
  description = "If running in EC2, also include the instance ID in the node name. This is needed in autoscaled environments, so nodes don't collide with each other if they get recycled/autoscaled."
  default     = "true"
}

variable "service_type" {
  description = "Type of service to use for Teleport. Either systemd or upstart"
  default     = "systemd"
}

variable "additional_labels" {
  type        = "list"
  description = "List of additional labels to add to the Teleport node. Every list item represents a label, with its key and value. Example: `[\"k8s_version: 1.10.10\", \"instance_type: t2.medium\"]`"
  default     = []
}
