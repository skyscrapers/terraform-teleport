locals {
  environment_label = var.environment == "" ? "" : "environment: ${var.environment}"
  project_label     = var.project == "" ? "" : "project: ${var.project}"
  function_label    = var.function == "" ? "" : "function: ${var.function}"
  default_labels = [
    local.environment_label,
    local.project_label,
    local.function_label,
  ]

  teleport_bootstrap_script = templatefile("${path.module}/templates/metadata.tpl", {
      function            = var.function
      project             = var.project == "" ? "" : "-${var.project}"
      environment         = var.environment == "" ? "" : "-${var.environment}"
      include_instance_id = var.include_instance_id
      auth_token          = var.auth_token
      auth_server         = var.auth_server
    }
  )

  teleport_config = templatefile("${path.module}/templates/teleport.yaml.tpl", {
      labels = indent(
        4,
        join(
          "\n",
          distinct(compact(concat(local.default_labels, var.additional_labels))),
        ),
      )
    }
  )

  teleport_config_cloudinit = templatefile("${path.module}/templates/teleport-cloudinit.yaml.tpl", {
      teleport_config = indent(4, local.teleport_config)
    }
  )
}
