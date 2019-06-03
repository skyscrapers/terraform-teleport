output "teleport_bootstrap_script" {
  description = "The rendered script to add to the Instance cloud-init user data"
  value       = data.template_file.teleport_bootstrap_script.rendered
}

output "teleport_config_cloudinit" {
  description = "The rendered Teleport config that you can add to the instance cloud-init user data"
  value       = data.template_file.teleport_config_cloudinit.rendered
}

output "teleport_service_cloudinit" {
  description = "The rendered Teleport systemd service that you can add to the instance cloud-init user data"
  value       = file("${path.module}/templates/teleport.service.yaml")
}
