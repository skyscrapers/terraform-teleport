output "teleport_bootstrap_script" {
  value = ["${data.template_file.teleport_bootstrap_script.rendered}"]
}
