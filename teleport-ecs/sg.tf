resource "aws_security_group_rule" "ecs_ingress_node" {
  security_group_id        = "${var.ecs_instances_sg_id}"
  type                     = "ingress"
  from_port                = "3022"
  to_port                  = "3022"
  protocol                 = "tcp"
  self                     = true
}

resource "aws_security_group_rule" "ecs_ingress_cli" {
  security_group_id        = "${var.ecs_instances_sg_id}"
  type                     = "ingress"
  from_port                = "3023"
  to_port                  = "3023"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.elb.id}"
}

resource "aws_security_group_rule" "ecs_ingress_tunnel" {
  security_group_id        = "${var.ecs_instances_sg_id}"
  type                     = "ingress"
  from_port                = "3024"
  to_port                  = "3024"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.elb.id}"
}

resource "aws_security_group_rule" "ecs_ingress_auth" {
  security_group_id = "${var.ecs_instances_sg_id}"
  type              = "ingress"
  from_port         = "3025"
  to_port           = "3025"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_ingress_web" {
  security_group_id        = "${var.ecs_instances_sg_id}"
  type                     = "ingress"
  from_port                = "3080"
  to_port                  = "3080"
  protocol                 = "tcp"
  source_security_group_id = "${aws_security_group.elb.id}"
}

resource "aws_security_group_rule" "ecs_egress_node" {
  security_group_id = "${var.ecs_instances_sg_id}"
  type              = "egress"
  from_port         = "3022"
  to_port           = "3022"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "ecs_egress_auth" {
  security_group_id = "${var.ecs_instances_sg_id}"
  type              = "egress"
  from_port         = "3025"
  to_port           = "3025"
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}
