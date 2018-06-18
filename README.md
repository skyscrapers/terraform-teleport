# terraform-teleport
Terraform module to provision Teleport related resources.

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
* [`service_type`]: String(optional): Type of service to use for Teleport. Either systemd or upstart. Defaults to systemd

### Outputs
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
data "template_cloudinit_config" "api_cloudinit" {
  gzip          = true
  base64_encode = true

  # Configure teleport
  part {
    content_type = "text/cloud-config"
    content =<<EOF
#cloud-config

write_files:
${module.teleport_bootstrap_script.teleport_config_cloudinit}
${module.teleport_bootstrap_script.teleport_service_cloudinit}
EOF
  }

  # Start teleport
  part {
    content_type = "text/x-shellscript"
    content      = "${module.teleport_bootstrap_script.teleport_bootstrap_script}"
  }
}

module "teleport_bootstrap_script" {
  source      = "github.com/skyscrapers/terraform-teleport//teleport-bootstrap-script?ref=1.0.0"
  auth_server = "tools01.customer.skyscrape.rs:3025"
  auth_token  = "something_really_really_secret"
  function    = "api"
  environment = "${terraform.workspace}"
}
```

## teleport-server

This module will deploy Teleport on an EC2 instance. The same server will run both `auth` and `proxy`. It'll also create an EIP and a Route53 record to be able to access Teleport.
The server will use Letsencrypt to retrieve a valid certificate for the Teleport server. It'll use the DNS challenge with Route53 to validate the domain name, but in case the Route53 sub-zone is not completely setup during the first boot and Letsencrypt fails to generate a valid certificate, the server will keep retrying until it does, and in the meantime, Teleport will use a self-signed certificate for the Web UI and API.

### Requirements

These are the requirements to apply this module:

- Teleport pre-built in an AMI: to avoid relying on external sources during boot time, all dependencies have to be present in the AMI, and that includes Teleport, certbot (with the Route53 plugin) and CloudWatch logs agent. Skyscrapers publishes and maintains [such an AMI](https://github.com/skyscrapers/server-images#teleport), and can be found with the filter: `owner-id`: "496014204152", `name`: "ebs-teleport-*", `tag:project`: "teleport".
- Route53 zone
- VPC and a subnet where to deploy the EC2 instance

### Available variables

* [`project`]: String(required): A project where this setup belongs to. Only for naming reasons.
* [`environment`]: String(required): The environment where this setup belongs to. Only for naming reasons.
* [`subnet_id`]: String(required): Subnet id where the EC2 instance will be deployed.
* [`key_name`]: String(required): SSH key name for the EC2 instance.
* [`r53_zone`]: String(required): The Route53 zone where to add the Teleport DNS record.
* [`ami_id`]: String(optional): AMI id for the EC2 instance. If omitted, it'll take the latest Skyscrapers' built AMI.
* [`teleport_subdomain`]: String(optional): DNS subdomain that will be created for the teleport server. Defaults to `"teleport"`.
* [`teleport_cluster_name`]: String(optional): Name of the teleport cluster. Defaults to `"${var.teleport_subdomain}.${var.r53_zone}"`.
* [`teleport_dynamodb_table`]: String(optional): Name of the DynamoDB table to configure in Teleport. Defaults to `"${var.teleport_subdomain}.${var.r53_zone}"`.
* [`instance_type`]: String(optional): Instance type for the EC2 instance. Defaults to `"t2.small"`.
* [`letsencrypt_email`]: String(optional): Email to use to register to letsencrypt. Defaults to `"letsencrypt@skyscrapers.eu"`.
* [`teleport_log_output`]: String(optional): Teleport logging configuration, possible values are `stdout`, `stderr` and `syslog`. Defaults to `"stdout"`
* [`teleport_log_severity`]: String(optional): Teleport logging configuration, possible severity values are `INFO`, `WARN` and `ERROR`. Defaults to `"ERROR"`
* [`teleport_auth_tokens`]: List(optional): List of static tokens to configure in the Teleport server. See the official documentation on static tokens [here](https://gravitational.com/teleport/docs/2.3/admin-guide/#static-tokens). Defaults to `[]`.
* [`teleport_session_recording`]: String(optional): Setting for configuring session recording in Teleport. Check the [official documentation](https://gravitational.com/teleport/docs/2.4/admin-guide/#configuration) for more info. Defaults to `"node"`.
* [`allowed_node_cidr_blocks`]: List(optional): CIDR blocks that are allowed to access the API interface in the `auth` server. Defaults to `["10.0.0.0/8"]`.
* [`allowed_cli_cidr_blocks`]: List(optional): CIDR blocks that are allowed to access the cli interface of the `proxy` server. Defaults to `["0.0.0.0/0"]`.
* [`allowed_web_cidr_blocks`]: List(optional): CIDR blocks that are allowed to access the web interface of the `proxy` server. Defaults to `["0.0.0.0/0"]`.
* [`allowed_tunnel_cidr_blocks`]: List(optional): CIDR blocks that are allowed to access the reverse tunnel interface of the `proxy` server. Defaults to `["0.0.0.0/0"]`.
* [`root_vl_type`]: String(optional): Volume type for the root volume of the EC2 instance. Can be `"standard"`, `"gp2"`, or `"io1"`. Defaults to `"gp2"`.
* [`root_vl_size`]: String(optional): Volume size for the root volume of the EC2 instance, in gigabytes. Defaults to `16`
* [`root_vl_delete`]: String(optional): Whether the root volume of the EC2 instance should be destroyed on instance termination. Defaults to `"true"`.
* [`acme_server`]: String(optional): ACME server where to point `certbot` on the Teleport server to fetch an SSL certificate. Useful if you want to point to the letsencrypt staging server. Defaults to `"https://acme-v01.api.letsencrypt.org/directory"`

### Outputs
* [`teleport_server_sg_id`]: String: Security group id of the Teleport server.
* [`teleport_server_instance_id`]: String: Instance id of the Teleport server.
* [`teleport_server_public_ip`]: String: Public IP of the Teleport server.
* [`teleport_server_private_ip`]: String: Private IP of the Teleport server.
* [`teleport_server_fqdn`]: String: FQDN of the DNS record of the Teleport server.
* [`teleport_server_instance_profile_id`]: String: Instance profile id of the Teleport server.
* [`teleport_server_instance_profile_arn`]: String: Instance profile ARN of the Teleport server.
* [`teleport_server_instance_profile_name`]: String: Instance profile name of the Teleport server.
* [`teleport_server_role_id`]: String: Role id of the Teleport server.
* [`teleport_server_role_arn`]: String: Role ARN of the Teleport server.
* [`teleport_server_role_name`]: String: Role name of the Teleport server.

### Example

```
module "teleport_ec2" {
  source                  = "github.com/skyscrapers/terraform-teleport//teleport-server?ref=3.0.0"
  ami                     = "ami-9d6324e4"
  teleport_auth_tokens    = ["${data.aws_kms_secret.teleport_tokens.trusted_cluster}", "${data.aws_kms_secret.teleport_tokens.node}"]
  environment             = "${terraform.workspace}"
  r53_zone                = "production.skyscrape.rs"
  project                 = "int"
  subnet_id               = "${data.terraform_remote_state.static.public_lb_subnets[0]}"
  key_name                = "iuri"
}
```

## teleport-node-sg-rules

This module will create the needed security group rules to allow a Teleport node to join a cluster. It requires the security groups of the three components (see "Available variables"), although both `proxy` and `auth` might run in the same server and have the same security group.

### Available variables:

* [`teleport_proxy_sg_id`]: String(required): Security group id of the `proxy` server.
* [`teleport_node_sg_id`]: String(required): Security group id of the `node` server.
* [`teleport_auth_sg_id`]: String(required): Security group id of the `auth` server.

### Outputs
\

### Example

```
module "teleport_vault_sg_rules" {
  teleport_proxy_sg_id = "${data.terraform_remote_state.teleport.teleport_server_sg_id}"
  teleport_node_sg_id  = "${module.ha_vault.sg_id}"
  teleport_auth_sg_id  = "${data.terraform_remote_state.teleport.teleport_server_sg_id}"
}
```
