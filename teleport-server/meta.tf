locals {
  teleport_domain_name    = "${var.teleport_subdomain}.${var.r53_zone}"
  teleport_dynamodb_table = "${length(var.teleport_dynamodb_table) > 0 ? var.teleport_dynamodb_table : local.teleport_domain_name}"
  teleport_cluster_name   = "${length(var.teleport_cluster_name) > 0 ? var.teleport_cluster_name : local.teleport_domain_name}"
}

data "aws_region" "current" {}

data "aws_route53_zone" "root" {
  name = "${var.r53_zone}"
}

data "aws_subnet" "teleport" {
  id = "${var.subnet_id}"
}

data "aws_ami" "teleport_ami" {
  count       = "${length(var.ami_id) > 0 ? 0 : 1}"
  most_recent = true

  name_regex = "^ebs-teleport-*"

  owners = ["496014204152"]
}
