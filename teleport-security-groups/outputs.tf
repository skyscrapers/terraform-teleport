output "auth_sg_id" {
  value = "${aws_security_group.teleport_auth.id}"
}

output "proxy_sg_id" {
  value = "${aws_security_group.teleport_proxy.id}"
}

output "node_sg_id" {
  value = "${aws_security_group.teleport_node.id}"
}
