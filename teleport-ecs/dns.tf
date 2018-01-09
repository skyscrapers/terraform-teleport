data "aws_route53_zone" "teleport" {
  name         = "${var.domain_name}."
}

data "aws_lb_listener" "alb" {
  arn = "${var.alb_listener_arn}"
}

data "aws_lb" "alb" {
  arn  = "${data.aws_lb_listener.alb.load_balancer_arn}"
}

resource "aws_route53_record" "teleport" {
  zone_id = "${data.aws_route53_zone.teleport.zone_id}"
  name    = "teleport.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${data.aws_lb.alb.dns_name}"
    zone_id                = "${data.aws_lb.alb.zone_id}"
    evaluate_target_health = true
  }
}
