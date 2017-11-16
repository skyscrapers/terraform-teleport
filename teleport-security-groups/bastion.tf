resource "aws_security_group" "teleport_bastion" {
  name_prefix = "teleport_bastion_"
  description = "Security group used by Teleport bastion node (auth & proxy)"
  vpc_id      = "${var.vpc_id}"
}

########## Auth related rules
resource "aws_security_group_rule" "teleport_auth_from_nodes" {
  type              = "ingress"
  from_port         = 3025
  to_port           = 3025
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"] # Right now the nodes access the auth server through its public IP address. TODO change it back when they can use the private one
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}

resource "aws_security_group_rule" "teleport_auth_from_proxy_self" {
  type              = "ingress"
  from_port         = 3025
  to_port           = 3025
  protocol          = "tcp"
  self              = "true"
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}

resource "aws_security_group_rule" "teleport_proxy_to_auth_self" {
  type              = "egress"
  from_port         = 3025
  to_port           = 3025
  protocol          = "tcp"
  self              = "true"
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}

########## Proxy related rules
resource "aws_security_group_rule" "teleport_ssh_proxy_from_world" {
  type              = "ingress"
  from_port         = 3023
  to_port           = 3023
  protocol          = "tcp"
  cidr_blocks       = "${var.cidr_blocks}"
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}

resource "aws_security_group_rule" "teleport_reverse_ssh_proxy_from_world" {
  type              = "ingress"
  from_port         = 3024
  to_port           = 3024
  protocol          = "tcp"
  cidr_blocks       = "${var.cidr_blocks}"
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}

resource "aws_security_group_rule" "teleport_https_proxy_from_world" {
  type              = "ingress"
  from_port         = 3080
  to_port           = 3080
  protocol          = "tcp"
  cidr_blocks       = "${var.cidr_blocks}"
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}

# These are needed for the trusted clusters feature, the auth server needs to connect to upstream Teleport clusters
resource "aws_security_group_rule" "teleport_https_auth_to_world" {
  type              = "egress"
  from_port         = 3080
  to_port           = 3080
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}
resource "aws_security_group_rule" "teleport_reverse_ssh_proxy_to_world" {
  type              = "egress"
  from_port         = 3024
  to_port           = 3024
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}

# Used by letsencrypt to obtain a certificate
resource "aws_security_group_rule" "teleport_le_http_proxy_from_world" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}

resource "aws_security_group_rule" "teleport_le_https_proxy_from_world" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}

resource "aws_security_group_rule" "teleport_proxy_to_nodes" {
  type                     = "egress"
  from_port                = 3022
  to_port                  = 3022
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.teleport_node.id}"
  security_group_id        = "${aws_security_group.teleport_bastion.id}"
}

resource "aws_security_group_rule" "teleport_proxy_to_nodes_self" {
  type              = "egress"
  from_port         = 3022
  to_port           = 3022
  protocol          = "tcp"
  self              = "true"
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}

############## Node related rules
resource "aws_security_group_rule" "teleport_nodes_from_proxy_self" {
  type              = "ingress"
  from_port         = 3022
  to_port           = 3022
  protocol          = "tcp"
  self              = "true"
  security_group_id = "${aws_security_group.teleport_bastion.id}"
}
