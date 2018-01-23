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

## teleport-ecs

This module will deploy Teleport on ECS. This takes care of the `auth` and `proxy` components.

These are the different ports that Teleport exposes, and the LB that they are attached to.

- `auth` port 3025: Used by nodes to register with the cluster. Mapped to the same port in the private NLB (ARN provided by parameter to this module).
- `proxy` port 3023: Used for clients to SSH into a node. Mapped to the same port in the public ELB.
- `proxy` port 3024: Used for other Teleport clusters to open a reverse tunnel (trusted clusters). Mapped to the same port in the public ELB.
- `proxy` port 3080: Used to serve the Web UI. Mapped to port 443 in the public ELB.

Audit logs generated in the `auth` server will be shipped to CloudWatch logs, it'll create a new log group named `"teleport_logs_${var.environment}_${var.project}"`.

### Available variables:
* [`cluster_name`]: String(required): Name of the cluster.
* [`domain_name`]: String(required): Domain name of where we want to reach our cluster. Example can be `company.com`
* [`nlb_private_arn`]: String(required): ARN for the private NLB to create a listener for the Node `auth` containers
* [`vpc_id`]: String(required): VPC ID of where we want to deploy Teleport in
* [`aws_region`]: String(optional): AWS region where the CloudWatch logs are located. Defaults to eu-west-1
* [`cpu`]: Integer(optional): The number of CPU units used by the task. It can be expressed as an integer using CPU units, for example 1024, or as a string using vCPUs, for example 1 vCPU or 1 vcpu, in a task definition but will be converted to an integer indicating the CPU units when the task definition is registered. Defaults to 128.
* [`dynamodb_table`]: String(optional): Which DynamoDB table does teleport need, teleport will create this table for you. You don't need to define anything in Terraform. Defaults to main.teleport
* [`dynamodb_region`]: String(optional): In which region does the DynamoDB table need to be created. Defaults to eu-west-1
* [`environment`]: String(optional): Environment where this node belongs to, will be the third part of the node name. Defaults to ''
* [`memory`]: Integer(optional): The amount of memory (in MiB) used by the task. It can be expressed as an integer using MiB, for example 1024, or as a string using GB, for example 1GB or 1 GB, in a task definition but will be converted to an integer indicating the MiB when the task definition is registered. Defaults to 128
* [`memory_reservation`]: Integer(optional): The soft limit (in MiB) of memory to reserve for the container. When system memory is under contention, Docker attempts to keep the container memory to this soft limit; however, your container can consume more memory when it needs to, up to either the hard limit specified with the memory parameter (if applicable), or all of the available memory on the container instance, whichever comes first. Defaults to 64
* [`project`]: String(optional): Project where this node belongs to, will be the second part of the node name. Defaults to ''
* [`teleport_version`]: String(optional): Teleport version you want to install. Defaults to 2.4.0
* [`tokens`]: List(optional): List of tokens you want to add to the authentication server. Defaults to []
* [`cw_logs_cpu`]: Integer(optional): The number of CPU units used by the CloudWatch logs task. It can be expressed as an integer using CPU units, for example 1024, or as a string using vCPUs, for example 1 vCPU or 1 vcpu, in a task definition but will be converted to an integer indicating the CPU units when the task definition is registered. Defaults to 128
* [`cw_logs_memory`]: Integer(optional): The amount of memory (in MiB) used by the CloudWatch logs task. It can be expressed as an integer using MiB, for example 1024, or as a string using GB, for example 1GB or 1 GB, in a task definition but will be converted to an integer indicating the MiB when the task definition is registered. Defaults to 128
* [`cw_logs_memory_reservation`]: Integer(optional): The soft limit (in MiB) of memory to reserve for the CloudWatch logs container. When system memory is under contention, Docker attempts to keep the container memory to this soft limit; however, your container can consume more memory when it needs to, up to either the hard limit specified with the memory parameter (if applicable), or all of the available memory on the container instance, whichever comes first. Defaults to 64
* [`elb_subnets`]: List(required): Subnets where to deploy the Teleport ELB
* [`web_ssl_certificate_arn`]: String(optional): ARN of the SSL certificate to use for the Teleport ELB
* [`web_allowed_cidr_blocks`]: List(optional): CIDR blocks that are allowed to access the web interface of the proxy server. Defaults to `["0.0.0.0/0"]`
* [`cli_allowed_cidr_blocks`]: List(optional): CIDR blocks that are allowed to access the cli interface of the proxy server. Defaults to `["0.0.0.0/0"]`
* [`tunnel_allowed_cidr_blocks`]: List(optional): CIDR blocks that are allowed to access the reverse tunnel interface of the proxy server. Defaults to `["0.0.0.0/0"]`
* [`ecs_instances_sg_id`]: String(required): Security group ID of the backend ECS instances running Teleport
* [`teleport_log_severity`]: String(optional): Logging configuration for Teleport, possible severity values are `INFO`, `WARN` and `ERROR`. Defaults to `ERROR`
* [`create_dns_record`]: String(optional): Create DNS records to reach teleport. Defaults to `"true"`

### Output
/

### Example
```
module "teleport" {
  source                  = "github.com/skyscrapers/terraform-teleport//teleport-ecs?ref=2.3.0"
  cluster_name            = "Skyscrapers-main"
  tokens                  = ["trusted_cluster:changeme", "node:changemetoo"]
  dynamodb_table          = "test.teleport.auth"
  environment             = "${terraform.workspace}"
  vpc_id                  = "${data.terraform_remote_state.static.vpc_id}"
  domain_name             = "production.skyscrape.rs"
  nlb_private_arn         = "${data.terraform_remote_state.loadbalancers.nlb_private_arn}"
  project                 = "int"
  ecs_cluster             = "${data.terraform_remote_state.ecs.ecs_cluster}"
  create_dns_record       = "true"
  ecs_instances_sg_id     = "${data.terraform_remote_state.ecs.sg_ecs_instance_id}"
  web_ssl_certificate_arn = "arn:aws:acm:eu-west-1:1924395464:certificate/234523-235tert-243fdf"
  elb_subnets             = "${data.terraform_remote_state.static.public_lb_subnets}"
}
```
