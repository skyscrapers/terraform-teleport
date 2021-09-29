resource "aws_security_group" "teleport_server" {
  name_prefix = "teleport_server_"
  description = "Teleport server specific rules"
  vpc_id      = data.aws_subnet.teleport.vpc_id

  tags = {
    Project     = var.project
    Environment = var.environment
  }
}

########## Auth related rules
resource "aws_security_group_rule" "teleport_auth_from_nodes" {
  type              = "ingress"
  from_port         = 3025
  to_port           = 3025
  protocol          = "tcp"
  cidr_blocks       = var.allowed_node_cidr_blocks
  security_group_id = aws_security_group.teleport_server.id
}

resource "aws_security_group_rule" "teleport_auth_from_proxy_self" {
  type              = "ingress"
  from_port         = 3025
  to_port           = 3025
  protocol          = "tcp"
  self              = "true"
  security_group_id = aws_security_group.teleport_server.id
}

resource "aws_security_group_rule" "teleport_proxy_to_auth_self" {
  type              = "egress"
  from_port         = 3025
  to_port           = 3025
  protocol          = "tcp"
  self              = "true"
  security_group_id = aws_security_group.teleport_server.id
}

########## Proxy related rules
resource "aws_security_group_rule" "teleport_ssh_proxy_from_world" {
  type              = "ingress"
  from_port         = 3023
  to_port           = 3023
  protocol          = "tcp"
  cidr_blocks       = var.allowed_cli_cidr_blocks
  security_group_id = aws_security_group.teleport_server.id
}

resource "aws_security_group_rule" "teleport_reverse_ssh_proxy_from_world" {
  type              = "ingress"
  from_port         = 3024
  to_port           = 3024
  protocol          = "tcp"
  cidr_blocks       = var.allowed_tunnel_cidr_blocks
  security_group_id = aws_security_group.teleport_server.id
}

resource "aws_security_group_rule" "teleport_kube_proxy_to_world" {
  type              = "ingress"
  from_port         = 3026
  to_port           = 3026
  protocol          = "tcp"
  cidr_blocks       = var.allowed_kube_cidr_blocks
  security_group_id = aws_security_group.teleport_server.id
}

resource "aws_security_group_rule" "teleport_https_proxy_from_world" {
  type              = "ingress"
  from_port         = 3080
  to_port           = 3080
  protocol          = "tcp"
  cidr_blocks       = var.allowed_web_cidr_blocks
  security_group_id = aws_security_group.teleport_server.id
}

# These are needed for the trusted clusters feature, the auth server needs to connect to upstream Teleport clusters
resource "aws_security_group_rule" "teleport_https_auth_to_world" {
  type              = "egress"
  from_port         = 3080
  to_port           = 3080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.teleport_server.id
}

resource "aws_security_group_rule" "teleport_reverse_ssh_proxy_to_world" {
  type              = "egress"
  from_port         = 3024
  to_port           = 3024
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.teleport_server.id
}

# Used by letsencrypt to obtain a certificate
resource "aws_security_group_rule" "teleport_le_http_proxy_from_world" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.teleport_server.id
}

resource "aws_security_group_rule" "teleport_le_https_proxy_from_world" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.teleport_server.id
}

############## Node related rules
resource "aws_security_group_rule" "teleport_proxy_to_nodes" {
  type              = "egress"
  from_port         = 3022
  to_port           = 3022
  protocol          = "tcp"
  cidr_blocks       = var.allowed_node_cidr_blocks
  security_group_id = aws_security_group.teleport_server.id
}

resource "aws_security_group_rule" "teleport_proxy_to_nodes_self" {
  type              = "egress"
  from_port         = 3022
  to_port           = 3022
  protocol          = "tcp"
  self              = "true"
  security_group_id = aws_security_group.teleport_server.id
}

resource "aws_security_group_rule" "teleport_nodes_from_proxy_self" {
  type              = "ingress"
  from_port         = 3022
  to_port           = 3022
  protocol          = "tcp"
  self              = "true"
  security_group_id = aws_security_group.teleport_server.id
}

############## General rules
resource "aws_security_group_rule" "internet_http_access" {
  type              = "egress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.teleport_server.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "internet_https_access" {
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.teleport_server.id
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ntp" {
  description       = "NTP (clock synchronization)"
  type              = "egress"
  from_port         = 123
  to_port           = 123
  protocol          = "udp"
  security_group_id = aws_security_group.teleport_server.id
  cidr_blocks       = ["0.0.0.0/0"]
}
