# terraform-teleport
Terraform module to provision Teleport related resources.

## teleport-auth-iam-policy

### Available variables:
* [`role_id`]: String(required): IAM role ID where to attach the Teleport policy.

### Output
-

### Example
```
module "teleport_iam_policy" {
  source  = "github.com/skyscrapers/terraform-teleport//teleport-auth-iam-policy?ref=1.0.0"
  role_id = "${module.tools.iam_role_id}"
}
```

## teleport-security-groups

Creates the security groups needed by all Teleport services, and the rules needed by Teleport.
It'll create two different security groups: `bastion` and `node`. Bastion contains all the rules for Teleport `proxy`, `auth` and `node` combined, to attach to a Teleport server; and the `node` security group is to attach the managed nodes.

### Available variables:
* [`vpc_id`]: String(required): The VPC where to put the security groups.
* [`cidr_blocks`]: List(optional): CIDR blocks from where to allow connections to the Teleport cluster. Defaults to ["0.0.0.0/0"]

### Output
 * [`bastion_sg_id`]: String: Security Group id for the Teleport server (`proxy`, `auth` and `node`).
 * [`node_sg_id`]: String: Security Group id for node.

### Example
```
module "security_groups_teleport" {
  source = "github.com/skyscrapers/terraform-teleport//teleport-security-groups?ref=1.0.0"
  vpc_id = "${module.vpc.vpc_id}"
}
```

## teleport-bootstrap-script

This module creates a script to configure and start the Teleport service on a server. It's useful on pre-built images, where everything is already setup on build-time but Teleport still needs to be configured with the actual node information, like private IP, node name and `auth` credentials. It uses `envsubst` to set the correct configuration into `/etc/teleport.yaml`, so the following environment variables need to be present in that file before running this script:

- `$ADVERTISE_IP`
- `$AUTH_TOKEN`
- `$AUTH_SERVER`
- `$NODENAME`

### Available variables:
* [`auth_server`]: String(required): Auth server that this node will connect to, including the port number.
* [`auth_token`]: String(required): Auth token that this node will present to the auth server.
* [`function`]: String(required): Function that this node performs, will be the first part of the node name.
* [`project`]: String(optional): Project where this node belongs to, will be the second part of the node name. Defaults to ''
* [`environment`]: String(optional): Environment where this node belongs to, will be the third part of the node name. Defaults to ''
* [`include_instance_id`]: String(optional): If running in EC2, also include the instance ID in the node name. This is needed in autoscaled environments, so nodes don't collide with each other if they get recycled/autoscaled. Defaults to true

### Output
 * [`teleport_bootstrap_script`]: String: The rendered script to add to the Instance cloud-init user data.
 * [`teleport_config_cloudinit`]: String: The rendered Teleport config that you can add to the instance cloud-init user data
 * [`teleport_service_cloudinit`]: String: The rendered Teleport systemd service that you can add to the instance cloud-init user data


The two cloudinit outputs can be used in the context of `write files`. Example:
```
write_files:
${teleport_config}
${teleport_service}
```

### Example
```
module "teleport_bootstrap_script" {
  source      = "github.com/skyscrapers/terraform-teleport//teleport-bootstrap-script?ref=1.0.0"
  auth_server = "tools01.customer.skyscrape.rs:3025"
  auth_token  = "something_really_really_secret"
  function    = "api"
  environment = "${terraform.workspace}"
}
```

## teleport-ecs_cluster

This module will deploy Teleport on ECS. This takes care of the auth and proxy components. All components are exposed through an public ALB (web), public NLB (tunnel/cli) and private NLB (node). An initial user is created so you can logon and start creating users.

### Available variables:
* [`alb_listener_arn`]: String(required): ARN for the ALB listener, this will be used to add a rule to for the Teleport web part
* [`cluster_name`]: String(required): Name of the cluster.
* [`domain_name`]: String(required): Domain name of where we want to reach our cluster. Example can be `company.com`
* [`nlb_arn`]: String(required): ARN for the NLB to create a listener for CLI and tunnel
* [`nlb_private_arn`]: String(required): ARN for the private NLB to create a listener for the Node auth containers
* [`vpc_id`]: String(required): VPC ID of where we want to deploy Teleport in
* [`aws_region`]: String(optional): AWS region where the cloudwatch logs are located. Defaults to eu-west-1
* [`cpu`]: Integer(optional): The number of CPU units used by the task. It can be expressed as an integer using CPU units, for example 1024, or as a string using vCPUs, for example 1 vCPU or 1 vcpu, in a task definition but will be converted to an integer indicating the CPU units when the task definition is registered. Defaults to 128.
* [`dynamodb_table`]: String(optional): Which dynamodb table does teleport need, teleport will create this table for you. You don't need to define anything in Terraform. Defaults to main.teleport
* [`dynamodb_region`]: String(optional): In which region does the dynamodb table need to be created. Defaults to eu-west-1
* [`environment`]: String(optional): Environment where this node belongs to, will be the third part of the node name. Defaults to ''
* [`memory`]: Integer(optional): The amount of memory (in MiB) used by the task. It can be expressed as an integer using MiB, for example 1024, or as a string using GB, for example 1GB or 1 GB, in a task definition but will be converted to an integer indicating the MiB when the task definition is registered. Defaults to 512
* [`memory_reservation`]: Integer(optional): The soft limit (in MiB) of memory to reserve for the container. When system memory is under contention, Docker attempts to keep the container memory to this soft limit; however, your container can consume more memory when it needs to, up to either the hard limit specified with the memory parameter (if applicable), or all of the available memory on the container instance, whichever comes first. Defaults to 254
* [`project`]: String(optional): Project where this node belongs to, will be the second part of the node name. Defaults to ''
* [`teleport_version`]: String(optional): Teleport version you want to install. Defaults to 2.3.7
* [`tokens`]: List(optional): List of tokens you want to add to the authentication server. Defaults to []

### Output
/

### Example
```
module "teleport" {
  source      = "github.com/skyscrapers/terraform-teleport//teleport-ecs?ref=2.3.0"
  cluster_name     = "Skyscrapers-main"
  tokens           = []
  dynamodb_table   = "test.teleport"
  environment      = "${terraform.workspace}"
  vpc_id           = "${data.terraform_remote_state.static.vpc_id}"
  domain_name      = "production.skyscrape.rs"
  alb_listener_arn = "${data.terraform_remote_state.loadbalancers.app_https_listener_id}"
  nlb_arn          = "${data.terraform_remote_state.loadbalancers.nlb_arn}"
  nlb_private_arn  = "${data.terraform_remote_state.loadbalancers.nlb_private_arn}"
  project          = "int"
  ecs_cluster      = "${data.terraform_remote_state.ecs.ecs_cluster}"
  create_dns_record = "false"
}

```
