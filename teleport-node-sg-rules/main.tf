resource "aws_security_group_rule" "teleport_nodes_from_proxy" {
  type                     = "ingress"
  from_port                = 3022
  to_port                  = 3022
  protocol                 = "tcp"
  source_security_group_id = "${var.teleport_proxy_sg_id}"
  security_group_id        = "${var.teleport_node_sg_id}"
}

resource "aws_security_group_rule" "teleport_nodes_to_auth" {
  type                     = "egress"
  from_port                = 3025
  to_port                  = 3025
  protocol                 = "tcp"
  source_security_group_id = "${var.teleport_auth_sg_id}"
  security_group_id        = "${var.teleport_node_sg_id}"
}
