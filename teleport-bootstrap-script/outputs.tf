output "teleport_bootstrap_script" {
  value = "${data.template_file.teleport_bootstrap_script.rendered}"
}

output "teleport_config_cloudinit" {
  value = "${data.template_file.teleport_config_cloudinit.rendered}"
}

output "teleport_service_cloudinit" {
  value = "${data.template_file.teleport_service_cloudinit.rendered}"
}
