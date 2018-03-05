locals {
  teleport_domain_name    = "${var.teleport_subdomain}.${var.r53_zone}"
  teleport_dynamodb_table = "${length(var.teleport_dynamodb_table) > 0 ? var.teleport_dynamodb_table : local.teleport_domain_name}"
  teleport_cluster_name   = "${length(var.teleport_cluster_name) > 0 ? var.teleport_cluster_name : local.teleport_domain_name}"
}

data "aws_region" "current" {
  current = true
}

data "aws_route53_zone" "root" {
  name = "${var.r53_zone}"
}

data "aws_subnet" "teleport" {
  id = "${var.subnet_id}"
}

data "aws_ami" "teleport_ami" {
  count       = "${length(var.ami_id) > 0 ? 0 : 1}"
  most_recent = true

  filter {
    name   = "tag:project"
    values = ["teleport"]
  }

  name_regex = "^ebs-teleport-*"

  owners = ["496014204152"]
}

variable "ebs_optimized_list" {
  type = "list"

  default = [
    "c1.xlarge",
    "c3.xlarge",
    "c3.2xlarge",
    "c3.4xlarge",
    "c4.large",
    "c4.xlarge",
    "c4.2xlarge",
    "c4.4xlarge",
    "c4.8xlarge",
    "c5.large",
    "c5.xlarge",
    "c5.2xlarge",
    "c5.4xlarge",
    "c5.9xlarge",
    "c5.18xlarge",
    "d2.xlarge",
    "d2.2xlarge",
    "d2.4xlarge",
    "d2.8xlarge",
    "f1.2xlarge",
    "f1.16xlarge",
    "g2.2xlarge",
    "g3.4xlarge",
    "g3.8xlarge",
    "g3.16xlarge",
    "h1.2xlarge",
    "h1.4xlarge",
    "h1.8xlarge",
    "h1.16xlarge",
    "i2.xlarge",
    "i2.2xlarge",
    "i2.4xlarge",
    "i3.large",
    "i3.xlarge",
    "i3.2xlarge",
    "i3.4xlarge",
    "i3.8xlarge",
    "i3.16xlarge",
    "m1.large",
    "m1.xlarge",
    "m2.2xlarge",
    "m2.4xlarge",
    "m3.xlarge",
    "m3.2xlarge",
    "m4.large",
    "m4.xlarge",
    "m4.2xlarge",
    "m4.4xlarge",
    "m4.10xlarge",
    "m4.16xlarge",
    "m5.large",
    "m5.xlarge",
    "m5.2xlarge",
    "m5.4xlarge",
    "m5.12xlarge",
    "m5.24xlarge",
    "p2.xlarge",
    "p2.8xlarge",
    "p2.16xlarge",
    "p3.2xlarge",
    "p3.8xlarge",
    "p3.16xlarge",
    "r3.xlarge",
    "r3.2xlarge",
    "r3.4xlarge",
    "r4.large",
    "r4.xlarge",
    "r4.2xlarge",
    "r4.4xlarge",
    "r4.8xlarge",
    "r4.16xlarge",
    "x1.16xlarge",
    "x1.32xlarge",
    "x1e.xlarge",
    "x1e.2xlarge",
    "x1e.4xlarge",
    "x1e.8xlarge",
    "x1e.16xlarge",
    "x1e.32xlarge",
  ]
}
