resource "aws_route53_record" "teleport" {
  zone_id = data.aws_route53_zone.root.zone_id
  name    = local.teleport_domain_name
  type    = "CNAME"
  records = [format(
    "ec2-%s.%s.compute.amazonaws.com",
    replace(aws_eip.teleport_public.public_ip, ".", "-"),
    data.aws_region.current.name,
  )] # Haven't found a better way to get the public_dns of the EIP
  ttl = "300"
}
