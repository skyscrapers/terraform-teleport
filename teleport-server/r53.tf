resource "aws_route53_record" "teleport" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = local.teleport_domain_name
  type    = "CNAME"
  records = [aws_eip.teleport_public.public_dns] # This way it resolves to the instance private IP within the VPC
  ttl     = "300"
}

resource "aws_route53_record" "teleport_sub" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = "*.${local.teleport_domain_name}"
  type    = "CNAME"
  records = [aws_eip.teleport_public.public_dns] # This way it resolves to the instance private IP within the VPC
  ttl     = "300"
}
