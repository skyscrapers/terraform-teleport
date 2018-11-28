# terraform-teleport

Terraform module to provision Teleport related resources.

## teleport-bootstrap-script

This module creates a script to configure and start the Teleport service on a server. It's useful on pre-built images, where everything is already setup on build-time but Teleport still needs to be configured with the actual node information, like private IP, node name and `auth` credentials. It uses `envsubst` to set the correct configuration into `/etc/teleport.yaml`, so the following environment variables need to be present in that file before running this script:

- `$ADVERTISE_IP`
- `$AUTH_TOKEN`
- `$AUTH_SERVER`
- `$NODENAME`

### Available variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_labels | List of additional labels to add to the Teleport node. Every list item represents a label, with its key and value. Example: `["k8s_version: 1.10.10", "instance_type: t2.medium"]` | list | `<list>` | no |
| auth_server | Auth server that this node will connect to, including the port number | string | - | yes |
| auth_token | Auth token that this node will present to the auth server. *Note* that this should be the bare token, without the type prefix. See the official [documentation on static tokens](https://gravitational.com/teleport/docs/2.3/admin-guide/#static-tokens) for more info. | string | - | yes |
| environment | Environment where this node belongs to, will be the third part of the node name. | string | `` | no |
| function | Function that this node performs, will be the first part of the node name. | string | - | yes |
| include_instance_id | If running in EC2, also include the instance ID in the node name. This is needed in autoscaled environments, so nodes don't collide with each other if they get recycled/autoscaled. | string | `true` | no |
| project | Project where this node belongs to, will be the second part of the node name. | string | `` | no |
| service_type | Type of service to use for Teleport. Either systemd or upstart | string | `systemd` | no |

### Outputs

| Name | Description |
|------|-------------|
| teleport_bootstrap_script | The rendered script to add to the Instance cloud-init user data |
| teleport_config_cloudinit | The rendered Teleport config that you can add to the instance cloud-init user data |
| teleport_service_cloudinit | The rendered Teleport systemd service that you can add to the instance cloud-init user data |

The two cloudinit outputs can be used in the context of `write files`. Example:

```yaml
write_files:
${teleport_config}
${teleport_service}
```

### Example

```tf
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

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| acme_server | ACME server where to point `certbot` on the Teleport server to fetch an SSL certificate. Useful if you want to point to the letsencrypt staging server. | string | `https://acme-v01.api.letsencrypt.org/directory` | no |
| allowed_cli_cidr_blocks | CIDR blocks that are allowed to access the cli interface of the `proxy` server. | string | `<list>` | no |
| allowed_node_cidr_blocks | CIDR blocks that are allowed to access the API interface in the `auth` server. | string | `<list>` | no |
| allowed_tunnel_cidr_blocks | CIDR blocks that are allowed to access the reverse tunnel interface of the `proxy` server. | string | `<list>` | no |
| allowed_web_cidr_blocks | CIDR blocks that are allowed to access the web interface of the `proxy` server. | string | `<list>` | no |
| ami_id | AMI id for the EC2 instance. | string | `` | no |
| environment | The environment where this setup belongs to. Only for naming reasons. | string | - | yes |
| instance_type | Instance type for the EC2 instance. | string | `t2.small` | no |
| key_name | SSH key name for the EC2 instance. | string | - | yes |
| letsencrypt_email | Email to use to register to letsencrypt. | string | `letsencrypt@skyscrapers.eu` | no |
| project | A project where this setup belongs to. Only for naming reasons. | string | - | yes |
| r53_zone | The Route53 zone where to add the Teleport DNS record. | string | - | yes |
| root_vl_delete | Whether the root volume of the EC2 instance should be destroyed on instance termination. | string | `true` | no |
| root_vl_size | Volume size for the root volume of the EC2 instance, in gigabytes. | string | `16` | no |
| root_vl_type | Volume type for the root volume of the EC2 instance. Can be `standard`, `gp2`, or `io1`. | string | `gp2` | no |
| subnet_id | Subnet id where the EC2 instance will be deployed. | string | - | yes |
| teleport_auth_tokens | List of static tokens to configure in the Teleport server. *Note* that these tokens will be added "as-is" in the Teleport configuration, so they must be pre-fixed with the token type. See the official [documentation on static tokens](https://gravitational.com/teleport/docs/admin-guide/#static-tokens) for more info. | string | `<list>` | no |
| teleport_cluster_name | Name of the teleport cluster. | string | `` | no |
| teleport_dynamodb_table | Name of the DynamoDB table to configure in Teleport. | string | `` | no |
| teleport_log_output | Teleport logging configuration, possible values are `stdout`, `stderr` and `syslog`. | string | `stdout` | no |
| teleport_log_severity | Teleport logging configuration, possible severity values are `INFO`, `WARN` and `ERROR`. | string | `ERROR` | no |
| teleport_session_recording | Setting for configuring session recording in Teleport. Check the [official documentation](https://gravitational.com/teleport/docs/admin-guide/#configuration) for more info. | string | `node` | no |
| teleport_subdomain | DNS subdomain that will be created for the teleport server. | string | `teleport` | no |

### Outputs

| Name | Description |
|------|-------------|
| teleport_server_fqdn | FQDN of the DNS record of the Teleport server. |
| teleport_server_instance_id | Instance id of the Teleport server. |
| teleport_server_instance_profile_arn | Instance profile ARN of the Teleport server. |
| teleport_server_instance_profile_id | Instance profile id of the Teleport server. |
| teleport_server_instance_profile_name | Instance profile name of the Teleport server. |
| teleport_server_private_ip | Private IP of the Teleport server. |
| teleport_server_public_ip | Public IP of the Teleport server. |
| teleport_server_role_arn | Role ARN of the Teleport server. |
| teleport_server_role_id | Role id of the Teleport server. |
| teleport_server_role_name | Role name of the Teleport server. |
| teleport_server_sg_id | Security group id of the Teleport server. |

### Example

```tf
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

### Available variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| teleport_auth_sg_id | Security group id of the `auth` server. | string | - | yes |
| teleport_node_sg_id | Security group id of the `node` server. | string | - | yes |
| teleport_proxy_sg_id | Security group id of the `proxy` server. | string | - | yes |

### Outputs

\

### Example

```tf
module "teleport_vault_sg_rules" {
  teleport_proxy_sg_id = "${data.terraform_remote_state.teleport.teleport_server_sg_id}"
  teleport_node_sg_id  = "${module.ha_vault.sg_id}"
  teleport_auth_sg_id  = "${data.terraform_remote_state.teleport.teleport_server_sg_id}"
}
```
