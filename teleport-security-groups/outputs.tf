output "bastion_sg_id" {
  value = "${aws_security_group.teleport_bastion.id}"
}

output "node_sg_id" {
  value = "${aws_security_group.teleport_node.id}"
}
