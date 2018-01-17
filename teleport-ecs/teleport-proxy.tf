resource "aws_ecs_task_definition" "teleport_proxy" {
  count                 = 3
  family                = "teleport-proxy-${local.functions[count.index]}"
  container_definitions = "${data.template_file.teleport_proxy.*.rendered[count.index]}"
  network_mode          = "bridge"
}

data "aws_lb" "nlb_node" {
  arn  = "${var.nlb_private_arn}"
}

data "template_file" "teleport_proxy" {
  count    = 3
  template = "${file("${path.module}/task-definitions/teleport-proxy.json")}"

  vars {
    cpu                = "${var.cpu}"
    memory             = "${var.memory}"
    memory_reservation = "${var.memory_reservation}"
    aws_region         = "${var.aws_region}"
    log_group          = "${aws_cloudwatch_log_group.teleport.id}"
    cluster_name       = "${var.cluster_name}"
    teleport_version   = "${var.teleport_version}"
    auth_servers       = "${data.aws_lb.nlb_node.dns_name}:3025"
    auth_token         = "${random_string.proxy_token.result}"
    function           = "${local.functions[count.index]}"
  }
}

locals {
  ports = ["3023","3024","3080"]
  functions = ["cli", "tunnel","web"]
  targets = ["${module.nlb_cli.target_group_arn}","${module.nlb_tunnel.target_group_arn}","${module.target.target_group_arn}"]
}


resource "aws_ecs_service" "teleport_proxy" {
  count           = 3
  name            = "teleport-proxy-${local.functions[count.index]}"
  cluster         = "${var.ecs_cluster}"
  task_definition = "${aws_ecs_task_definition.teleport_proxy.*.arn[count.index]}"
  desired_count   = "${var.desired_count}"

  load_balancer {
    target_group_arn = "${local.targets[count.index]}"
    container_name   = "teleport-proxy"
    container_port   = "${local.ports[count.index]}"
  }

  placement_strategy {
    type  = "spread"
    field = "attribute:ecs.availability-zone"
  }

  placement_strategy {
    type  = "spread"
    field = "instanceId"
  }
}
