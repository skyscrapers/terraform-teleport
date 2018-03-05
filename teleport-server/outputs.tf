output "teleport_server_sg_id" {
  value = "${aws_security_group.teleport_server.id}"
}

output "teleport_server_instance_id" {
  value = "${aws_instance.teleport_instance.id}"
}

output "teleport_server_public_ip" {
  value = "${aws_eip.teleport_public.public_ip}"
}

output "teleport_server_private_ip" {
  value = "${aws_eip.teleport_public.private_ip}"
}

output "teleport_server_fqdn" {
  value = "${aws_route53_record.teleport.fqdn}"
}

output "teleport_server_instance_profile_id" {
  value = "${aws_iam_instance_profile.profile.id}"
}

output "teleport_server_instance_profile_arn" {
  value = "${aws_iam_instance_profile.profile.arn}"
}

output "teleport_server_instance_profile_name" {
  value = "${aws_iam_instance_profile.profile.name}"
}

output "teleport_server_role_id" {
  value = "${aws_iam_role.role.unique_id}"
}

output "teleport_server_role_arn" {
  value = "${aws_iam_role.role.arn}"
}

output "teleport_server_role_name" {
  value = "${aws_iam_role.role.name}"
}
