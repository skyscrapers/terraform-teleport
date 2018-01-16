data "aws_route53_zone" "teleport" {
  count = "${var.create_dns_record ? 1 : 0}"
  name  = "${var.domain_name}."
}

resource "aws_route53_record" "teleport" {
  count   = "${var.create_dns_record ? 1 : 0}"
  zone_id = "${data.aws_route53_zone.teleport.zone_id}"
  name    = "teleport.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_elb.proxy.dns_name}"
    zone_id                = "${aws_elb.proxy.zone_id}"
    evaluate_target_health = true
  }
}
