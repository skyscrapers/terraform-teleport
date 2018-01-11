module "nlb_auth" {
  source                = "github.com/skyscrapers/terraform-loadbalancers//nlb_listener?ref=5.1.1"
  environment           = "${var.environment}"
  project               = "${var.project}"
  vpc_id                = "${var.vpc_id}"
  name_prefix           = "auth"
  nlb_arn               = "${var.nlb_private_arn}"
  ingress_port          = "3025"

  tags = {
    Role = "loadbalancer"
  }
}

resource "aws_elb" "proxy" {
  name                        = "teleport-proxy-${var.project}-${var.environment}"
  subnets                     = ["${var.elb_subnets}"]
  internal                    = "false"
  cross_zone_load_balancing   = true
  idle_timeout                = "60"
  connection_draining         = "true"
  connection_draining_timeout = "60"
  security_groups             = ["${aws_security_group.elb.id}"]

  listener {
    instance_port     = "3023"
    instance_protocol = "tcp"
    lb_port           = "3023"
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = "3024"
    instance_protocol = "tcp"
    lb_port           = "3024"
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = "3080"
    instance_protocol = "https"
    lb_port           = "443"
    lb_protocol       = "https"
    ssl_certificate_id = "${var.web_ssl_certificate_arn}"
  }

  health_check {
    healthy_threshold   = "3"
    unhealthy_threshold = "2"
    timeout             = "10"
    target              = "HTTPS:3080/webapi/ping"
    interval            = "30"
  }

  tags {
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

resource "aws_security_group" "elb" {
  name_prefix = "teleport-proxy-elb-${var.project}-${var.environment}-"
  description = "Security group for Teleport proxy on ${var.environment} for ${var.project}"
  vpc_id      = "${var.vpc_id}"
}

resource "aws_security_group_rule" "web_from_world" {
  security_group_id = "${aws_security_group.elb.id}"
  type              = "ingress"
  from_port         = "443"
  to_port           = "443"
  protocol          = "tcp"
  cidr_blocks       = "${var.web_allowed_cidr_blocks}"
}

resource "aws_security_group_rule" "cli_from_world" {
  security_group_id = "${aws_security_group.elb.id}"
  type              = "ingress"
  from_port         = "3023"
  to_port           = "3023"
  protocol          = "tcp"
  cidr_blocks       = "${var.cli_allowed_cidr_blocks}"
}

resource "aws_security_group_rule" "tunnel_from_world" {
  security_group_id = "${aws_security_group.elb.id}"
  type              = "ingress"
  from_port         = "3024"
  to_port           = "3024"
  protocol          = "tcp"
  cidr_blocks       = "${var.tunnel_allowed_cidr_blocks}"
}

resource "aws_security_group_rule" "web_to_instances" {
  security_group_id        = "${aws_security_group.elb.id}"
  type                     = "egress"
  from_port                = "3080"
  to_port                  = "3080"
  protocol                 = "tcp"
  source_security_group_id = "${var.ecs_instances_sg_id}"
}

resource "aws_security_group_rule" "cli_to_instances" {
  security_group_id        = "${aws_security_group.elb.id}"
  type                     = "egress"
  from_port                = "3023"
  to_port                  = "3023"
  protocol                 = "tcp"
  source_security_group_id = "${var.ecs_instances_sg_id}"
}

resource "aws_security_group_rule" "tunnel_to_instances" {
  security_group_id        = "${aws_security_group.elb.id}"
  type                     = "egress"
  from_port                = "3024"
  to_port                  = "3024"
  protocol                 = "tcp"
  source_security_group_id = "${var.ecs_instances_sg_id}"
}
