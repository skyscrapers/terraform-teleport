data "template_file" "teleport_bootstrap_script" {
  template = "${file("${path.module}/templates/metadata.tpl")}"

  vars {
    function            = "${var.function}"
    project             = "${var.project == "" ? "" : "-${var.project}"}"
    environment         = "${var.environment == "" ? "" : "-${var.environment}"}"
    include_instance_id = "${var.include_instance_id}"
    auth_token          = "${var.auth_token}"
    auth_server         = "${var.auth_server}"
  }
}

data "template_file" "teleport_config" {
  template = "${file("${path.module}/templates/teleport.yaml.tpl")}"

  vars {
    environment = "${var.environment}"
    project     = "${var.project}"
    function    = "${var.function}"
  }
}

data "template_file" "teleport_service_cloudinit" {
  template = "${file("${path.module}/templates/teleport.service.tpl")}"

  vars {
    teleport_service  = "${indent(4,file("${path.module}/templates/${var.service_type == "systemd" ? "teleport.service" : "teleport-upstart.conf"}"))}"
    service_type_path = "${var.service_type == "systemd" ? "/lib/systemd/system/teleport.service" : "/etc/init.d/teleport"}"
    file_permissions  = "${var.service_type == "systemd" ? "0644" : "0755"}"
  }
}

data "template_file" "teleport_config_cloudinit" {
  template = "${file("${path.module}/templates/teleport-cloudinit.yaml.tpl")}"

  vars {
    teleport_config = "${indent(4,data.template_file.teleport_config.rendered)}"
  }
}
