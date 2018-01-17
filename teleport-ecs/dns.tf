data "aws_route53_zone" "teleport" {
  count = "${var.create_dns_record ? 1 : 0}"
  name  = "${var.domain_name}."
}

data "aws_lb_listener" "alb" {
  count = "${var.create_dns_record ? 1 : 0}"
  arn   = "${var.alb_listener_arn}"
}

data "aws_lb" "alb" {
  count = "${var.create_dns_record ? 1 : 0}"
  arn   = "${data.aws_lb_listener.alb.load_balancer_arn}"
}

data "aws_lb" "nlb" {
  count = "${var.create_dns_record ? 1 : 0}"
  arn   = "${var.nlb_arn}"
}

resource "aws_route53_record" "teleport" {
  count   = "${var.create_dns_record ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.teleport.zone_id}"
  name    = "teleport.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${data.aws_lb.alb.dns_name}"
    zone_id                = "${data.aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "teleport_tsh" {
  count   = "${var.create_dns_record ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.teleport.zone_id}"
  name    = "tsh.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${data.aws_lb.nlb.dns_name}"
    zone_id                = "${data.aws_lb.nlb.zone_id}"
    evaluate_target_health = true
  }
}
