module "target" {
  source                    = "github.com/skyscrapers/terraform-loadbalancers//alb_rule_target?ref=5.0.4"
  name                      = "teleport-web"
  environment               = "${var.environment}"
  project                   = "${var.project}"
  vpc_id                    = "${var.vpc_id}"
  listener_arn              = "${var.alb_listener_arn}"
  listener_priority         = 100
  listener_condition_field  = "host-header"
  listener_condition_values = ["teleport.${var.domain_name}"]
  target_port               = "3080"
  target_protocol           = "HTTPS"
  target_health_path        = "/web"

  tags = {
    Role = "loadbalancer"
  }
}

module "nlb_cli" {
  source                = "github.com/skyscrapers/terraform-loadbalancers//nlb_listener?ref=5.0.3"
  environment           = "${var.environment}"
  project               = "${var.project}"
  vpc_id                = "${var.vpc_id}"
  name_prefix           = "cli"
  nlb_arn               = "${var.nlb_arn}"
  ingress_port          = "3023"

  tags = {
    Role = "loadbalancer"
  }
}

module "nlb_tunnel" {
  source                = "github.com/skyscrapers/terraform-loadbalancers//nlb_listener?ref=5.0.3"
  environment           = "${var.environment}"
  project               = "${var.project}"
  vpc_id                = "${var.vpc_id}"
  name_prefix           = "tunnel"
  nlb_arn               = "${var.nlb_arn}"
  ingress_port          = "3024"

  tags = {
    Role = "loadbalancer"
  }
}

module "nlb_node" {
  source                = "github.com/skyscrapers/terraform-loadbalancers//nlb_listener?ref=5.0.3"
  environment           = "${var.environment}"
  project               = "${var.project}"
  vpc_id                = "${var.vpc_id}"
  name_prefix           = "node"
  nlb_arn               = "${var.nlb_private_arn}"
  ingress_port          = "3025"

  tags = {
    Role = "loadbalancer"
  }
}
