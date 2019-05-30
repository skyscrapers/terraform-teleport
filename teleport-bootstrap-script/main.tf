data "template_file" "teleport_bootstrap_script" {
  template = file("${path.module}/templates/metadata.tpl")

  vars = {
    function            = var.function
    project             = var.project == "" ? "" : "-${var.project}"
    environment         = var.environment == "" ? "" : "-${var.environment}"
    include_instance_id = var.include_instance_id
    auth_token          = var.auth_token
    auth_server         = var.auth_server
  }
}

locals {
  environment_label = var.environment == "" ? "" : "environment: ${var.environment}"
  project_label     = var.project == "" ? "" : "project: ${var.project}"
  function_label    = var.function == "" ? "" : "function: ${var.function}"
  default_labels = [
    local.environment_label,
    local.project_label,
    local.function_label,
  ]
}

data "template_file" "teleport_config" {
  template = file("${path.module}/templates/teleport.yaml.tpl")

  vars = {
    labels = indent(
      4,
      join(
        "\n",
        distinct(compact(concat(local.default_labels, var.additional_labels))),
      ),
    )
  }
}

data "template_file" "teleport_config_cloudinit" {
  template = file("${path.module}/templates/teleport-cloudinit.yaml.tpl")

  vars = {
    teleport_config = indent(4, data.template_file.teleport_config.rendered)
  }
}
