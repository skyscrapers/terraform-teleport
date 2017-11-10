resource "aws_security_group" "teleport_node" {
  name_prefix = "teleport_node_"
  description = "Security group used by Teleport nodes"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "teleport_nodes_from_proxy" {
  type                     = "ingress"
  from_port                = 3022
  to_port                  = 3022
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.teleport_bastion.id}"
  security_group_id        = "${aws_security_group.teleport_node.id}"
}

resource "aws_security_group_rule" "teleport_nodes_to_auth" {
  type                     = "egress"
  from_port                = 3025
  to_port                  = 3025
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.teleport_bastion.id}"
  security_group_id        = "${aws_security_group.teleport_node.id}"
}
