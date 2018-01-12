resource "aws_ecs_task_definition" "teleport_proxy" {
  family                = "teleport-proxy"
  container_definitions = "${data.template_file.teleport_proxy.rendered}"
  network_mode          = "bridge"
}

data "aws_lb" "nlb_node" {
  arn  = "${var.nlb_private_arn}"
}

data "template_file" "teleport_proxy" {
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
    log_severity       = "${var.teleport_log_severity}"
  }
}

resource "aws_ecs_service" "teleport_proxy" {
  name            = "teleport-proxy"
  cluster         = "${var.ecs_cluster}"
  task_definition = "${aws_ecs_task_definition.teleport_proxy.arn}"
  desired_count   = "1"

  load_balancer {
    elb_name       = "${aws_elb.proxy.name}"
    container_name = "teleport-proxy"
    container_port = "3080"
  }
}
