locals {
  teleport_domain_name    = "${var.teleport_subdomain}.${var.r53_zone}"
  teleport_dynamodb_table = coalesce(var.teleport_dynamodb_table, local.teleport_domain_name)
  teleport_cluster_name   = coalesce(var.teleport_cluster_name, local.teleport_domain_name)
}

data "aws_region" "current" {
}

data "aws_route53_zone" "root" {
  name = var.r53_zone
}

data "aws_subnet" "teleport" {
  id = var.subnet_id
}

data "aws_ami" "teleport_ami" {
  count       = var.ami_id != null ? 0 : 1
  most_recent = true
  name_regex  = "^ebs-teleport-${var.teleport_version != null ? "${var.teleport_version}-" : ""}*"
  owners      = ["496014204152"]
}
