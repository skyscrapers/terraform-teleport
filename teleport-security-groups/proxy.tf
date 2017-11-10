resource "aws_security_group" "teleport_proxy" {
  name_prefix = "teleport_proxy_"
  description = "Security group used by Teleport proxy nodes"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "teleport_ssh_world_to_proxy" {
  type              = "ingress"
  from_port         = 3023
  to_port           = 3023
  protocol          = "tcp"
  cidr_blocks       = "${var.cidr_blocks}"
  security_group_id = "${aws_security_group.teleport_proxy.id}"
}

resource "aws_security_group_rule" "teleport_reverse_ssh_world_to_proxy" {
  type              = "ingress"
  from_port         = 3024
  to_port           = 3024
  protocol          = "tcp"
  cidr_blocks       = "${var.cidr_blocks}"
  security_group_id = "${aws_security_group.teleport_proxy.id}"
}

resource "aws_security_group_rule" "teleport_https_world_to_proxy" {
  type              = "ingress"
  from_port         = 3080
  to_port           = 3080
  protocol          = "tcp"
  cidr_blocks       = "${var.cidr_blocks}"
  security_group_id = "${aws_security_group.teleport_proxy.id}"
}

# Used by letsencrypt to obtain a certificate
resource "aws_security_group_rule" "teleport_http_world_to_proxy" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.teleport_proxy.id}"
}

resource "aws_security_group_rule" "teleport_proxy_to_auth" {
  type                     = "egress"
  from_port                = 3025
  to_port                  = 3025
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.teleport_auth.id}"
  security_group_id        = "${aws_security_group.teleport_proxy.id}"
}

resource "aws_security_group_rule" "teleport_proxy_to_nodes" {
  type                     = "egress"
  from_port                = 3022
  to_port                  = 3022
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.teleport_node.id}"
  security_group_id        = "${aws_security_group.teleport_proxy.id}"
}
