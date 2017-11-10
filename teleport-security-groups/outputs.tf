output "bastion_sg_id" {
  value = "${aws_security_group.teleport_auth.id}"
}

output "node_sg_id" {
  value = "${aws_security_group.teleport_node.id}"
}
