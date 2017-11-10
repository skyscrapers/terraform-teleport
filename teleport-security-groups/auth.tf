resource "aws_security_group" "teleport_auth" {
  name_prefix = "teleport_auth_"
  description = "Security group used by Teleport auth nodes"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "teleport_auth_from_nodes" {
  type                     = "ingress"
  from_port                = 3025
  to_port                  = 3025
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.teleport_node.id}"
  security_group_id        = "${aws_security_group.teleport_auth.id}"
}

resource "aws_security_group_rule" "teleport_auth_from_proxy" {
  type                     = "ingress"
  from_port                = 3025
  to_port                  = 3025
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.teleport_proxy.id}"
  security_group_id        = "${aws_security_group.teleport_auth.id}"
}
