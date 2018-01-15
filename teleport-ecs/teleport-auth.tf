resource "aws_ecs_task_definition" "teleport_auth" {
  family                = "teleport-auth"
  container_definitions = "${data.template_file.teleport_auth.rendered}"
  network_mode          = "bridge"
  task_role_arn         = "${aws_iam_role.teleport.arn}"
}

resource "random_string" "proxy_token" {
  length  = 48
  special = false
}

data "template_file" "teleport_auth" {
  template = "${file("${path.module}/task-definitions/teleport-auth.json")}"

  vars {
    cpu                        = "${var.cpu}"
    memory                     = "${var.memory}"
    memory_reservation         = "${var.memory_reservation}"
    cw_logs_cpu                = "${var.cw_logs_cpu}"
    cw_logs_memory             = "${var.cw_logs_memory}"
    cw_logs_memory_reservation = "${var.cw_logs_memory_reservation}"
    aws_region                 = "${var.aws_region}"
    log_group                  = "${aws_cloudwatch_log_group.teleport.id}"
    teleport_version           = "${var.teleport_version}"
    cluster_name               = "${var.cluster_name}"
    dynamodb_table             = "${var.dynamodb_table}.auth"
    dynamodb_region            = "${var.dynamodb_region}"
    auth_token                 = "${random_string.proxy_token.result}"
    tokens                     = "${join(" ", concat(var.tokens, list("proxy,node:${random_string.proxy_token.result}")))}"
    log_severity               = "${var.teleport_log_severity}"
  }
}

resource "aws_ecs_service" "teleport_auth" {
  name            = "teleport-auth"
  cluster         = "${var.ecs_cluster}"
  task_definition = "${aws_ecs_task_definition.teleport_auth.arn}"
  desired_count   = "1"

  load_balancer {
    target_group_arn = "${module.nlb_auth.target_group_arn}"
    container_name   = "teleport-auth"
    container_port   = "3025"
  }

  placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  placement_strategy {
    type  = "spread"
    field = "instanceId"
  }

  placement_constraints {
    type = "distinctInstance"
  }
}
