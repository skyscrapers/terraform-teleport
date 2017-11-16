data "template_file" "teleport_bootstrap_script" {
  template = "${file("${path.module}/metadata.tpl")}"

  vars {
    function            = "${var.function}"
    project             = "${var.project == "" ? "" : "-${var.project}"}"
    environment         = "${var.environment == "" ? "" : "-${var.environment}"}"
    include_instance_id = "${var.include_instance_id}"
    auth_token          = "${var.auth_token}"
    auth_server         = "${var.auth_server}"
  }
}
