# terraform-teleport

Terraform module to provision Teleport related resources.

Starting from version 5.0.0, this module uses Terraform 0.12 syntax.

## teleport-bootstrap-script

This module creates a script to configure and start the Teleport service on a server. It's useful on pre-built images, where everything is already setup on build-time but Teleport still needs to be configured with the actual node information, like private IP, node name and `auth` credentials. It uses `envsubst` to set the correct configuration into `/etc/teleport.yaml`, so the following environment variables need to be present in that file before running this script:

- `$ADVERTISE_IP`
- `$AUTH_TOKEN`
- `$AUTH_SERVER`
- `$NODENAME`

### Available variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional\_labels | List of additional labels to add to the Teleport node. Every list item represents a label, with its key and value. Example: `["k8s_version: 1.10.10", "instance_type: t2.medium"]` | list(string) | `[]` | no |
| auth\_server | Auth server that this node will connect to, including the port number | string | n/a | yes |
| auth\_token | Auth token that this node will present to the auth server. **Note** that this should be the bare token, without the type prefix. See the official [documentation on static tokens](https://gravitational.com/teleport/docs/2.3/admin-guide/#static-tokens) for more info | string | n/a | yes |
| environment | Environment where this node belongs to, will be the third part of the node name | string | `""` | no |
| function | Function that this node performs, will be the first part of the node name | string | n/a | yes |
| include\_instance\_id | If running in EC2, also include the instance ID in the node name. This is needed in autoscaled environments, so nodes don't collide with each other if they get recycled/autoscaled | bool | `true` | no |
| project | Project where this node belongs to, will be the second part of the node name | string | `""` | no |

### Outputs

| Name | Description |
|------|-------------|
| teleport\_bootstrap\_script | The rendered script to add to the Instance cloud-init user data |
| teleport\_config\_cloudinit | The rendered Teleport config that you can add to the instance cloud-init user data |
| teleport\_service\_cloudinit | The rendered Teleport systemd service that you can add to the instance cloud-init user data |

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

- Teleport pre-built in an AMI: to avoid relying on external sources during boot time, all dependencies have to be present in the AMI, and that includes Teleport and the CloudWatch logs agent. Skyscrapers publishes and maintains [such an AMI](https://github.com/skyscrapers/server-images#teleport), and can be found with the filter:
  - `owner-id`: "496014204152"
  - `name`: "ebs-teleport-*"
  - `tag:project`: "teleport"
- Route53 zone
- VPC and a subnet where to deploy the EC2 instance

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform) | >= 0.12 |

### Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider_aws) | n/a |
| <a name="provider_template"></a> [template](#provider_template) | n/a |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [aws_cloudwatch_log_group.teleport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_cloudwatch_log_group.teleport_audit](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_eip.teleport_public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eip) | resource |
| [aws_iam_instance_profile.profile](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_instance_profile) | resource |
| [aws_iam_role.role](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy.policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy) | resource |
| [aws_instance.teleport_instance](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/instance) | resource |
| [aws_route53_record.teleport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_record.teleport_sub](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_s3_bucket.sessions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket) | resource |
| [aws_s3_bucket_public_access_block.sessions](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/s3_bucket_public_access_block) | resource |
| [aws_security_group.teleport_server](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group_rule.internet_http_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.internet_https_access](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.ntp](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_auth_from_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_auth_from_proxy_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_https_auth_to_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_https_proxy_from_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_le_http_proxy_from_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_le_https_proxy_from_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_nodes_from_proxy_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_proxy_to_auth_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_proxy_to_nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_proxy_to_nodes_self](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_reverse_ssh_proxy_from_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_reverse_ssh_proxy_to_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_security_group_rule.teleport_ssh_proxy_from_world](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group_rule) | resource |
| [aws_ami.teleport_ami](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/ami) | data source |
| [aws_iam_policy_document.teleport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region) | data source |
| [aws_route53_zone.root](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/route53_zone) | data source |
| [aws_subnet.teleport](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/subnet) | data source |
| [template_cloudinit_config.teleport](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/cloudinit_config) | data source |
| [template_file.cloudinit_teleport](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_environment"></a> [environment](#input_environment) | The environment where this setup belongs to. Only for naming reasons | `string` | n/a | yes |
| <a name="input_letsencrypt_email"></a> [letsencrypt_email](#input_letsencrypt_email) | Email to use to register to letsencrypt | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input_project) | A project where this setup belongs to. Only for naming reasons | `string` | n/a | yes |
| <a name="input_r53_zone"></a> [r53_zone](#input_r53_zone) | The Route53 zone where to add the Teleport DNS record | `string` | n/a | yes |
| <a name="input_subnet_id"></a> [subnet_id](#input_subnet_id) | Subnet id where the EC2 instance will be deployed | `string` | n/a | yes |
| <a name="input_allowed_cli_cidr_blocks"></a> [allowed_cli_cidr_blocks](#input_allowed_cli_cidr_blocks) | CIDR blocks that are allowed to access the cli interface of the `proxy` server | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_allowed_node_cidr_blocks"></a> [allowed_node_cidr_blocks](#input_allowed_node_cidr_blocks) | CIDR blocks that are allowed to access the API interface in the `auth` server | `list(string)` | <pre>[<br>  "10.0.0.0/8"<br>]</pre> | no |
| <a name="input_allowed_tunnel_cidr_blocks"></a> [allowed_tunnel_cidr_blocks](#input_allowed_tunnel_cidr_blocks) | CIDR blocks that are allowed to access the reverse tunnel interface of the `proxy` server | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_allowed_web_cidr_blocks"></a> [allowed_web_cidr_blocks](#input_allowed_web_cidr_blocks) | CIDR blocks that are allowed to access the web interface of the `proxy` server | `list(string)` | <pre>[<br>  "0.0.0.0/0"<br>]</pre> | no |
| <a name="input_ami_id"></a> [ami_id](#input_ami_id) | AMI id for the EC2 instance | `string` | `null` | no |
| <a name="input_instance_ebs_optimized"></a> [instance_ebs_optimized](#input_instance_ebs_optimized) | If true, the launched EC2 instance will be EBS-optimized. Note that if this is not set on an instance type that is optimized by default then this will show as disabled but if the instance type is optimized by default then there is no need to set this and there is no effect to disabling it. See the [EBS Optimized section](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/EBSOptimized.html) of the AWS User Guide for more information | `bool` | `null` | no |
| <a name="input_instance_type"></a> [instance_type](#input_instance_type) | Instance type for the EC2 instance | `string` | `"t3.small"` | no |
| <a name="input_key_name"></a> [key_name](#input_key_name) | SSH key name for the EC2 instance | `string` | `null` | no |
| <a name="input_log_retention_period"></a> [log_retention_period](#input_log_retention_period) | Amount of days to keep the logs | `number` | `30` | no |
| <a name="input_root_vl_delete"></a> [root_vl_delete](#input_root_vl_delete) | Whether the root volume of the EC2 instance should be destroyed on instance termination | `bool` | `true` | no |
| <a name="input_root_vl_encrypted"></a> [root_vl_encrypted](#input_root_vl_encrypted) | Whether the root volume of the EC2 instance should be encrypted | `bool` | `true` | no |
| <a name="input_root_vl_size"></a> [root_vl_size](#input_root_vl_size) | Volume size for the root volume of the EC2 instance, in gigabytes | `number` | `16` | no |
| <a name="input_root_vl_type"></a> [root_vl_type](#input_root_vl_type) | Volume type for the root volume of the EC2 instance. Can be `standard`, `gp2`, or `io1` | `string` | `"gp2"` | no |
| <a name="input_teleport_auth_tokens"></a> [teleport_auth_tokens](#input_teleport_auth_tokens) | List of static tokens to configure in the Teleport server. **Note** that these tokens will be added "as-is" in the Teleport configuration, so they must be pre-fixed with the token type (e.g. `teleport_auth_tokens = ["node:sdf34asd7f832efhsdnfsjdfh3i24788923r"]`). See the official [documentation on static tokens](https://gravitational.com/teleport/docs/admin-guide/#static-tokens) for more info | `list(string)` | `[]` | no |
| <a name="input_teleport_cluster_name"></a> [teleport_cluster_name](#input_teleport_cluster_name) | Name of the teleport cluster | `string` | `null` | no |
| <a name="input_teleport_dynamodb_table"></a> [teleport_dynamodb_table](#input_teleport_dynamodb_table) | Name of the DynamoDB table to configure in Teleport | `string` | `null` | no |
| <a name="input_teleport_log_output"></a> [teleport_log_output](#input_teleport_log_output) | Teleport logging configuration, possible values are `stdout`, `stderr` and `syslog` | `string` | `"stdout"` | no |
| <a name="input_teleport_log_severity"></a> [teleport_log_severity](#input_teleport_log_severity) | Teleport logging configuration, possible severity values are `INFO`, `WARN` and `ERROR` | `string` | `"ERROR"` | no |
| <a name="input_teleport_session_recording"></a> [teleport_session_recording](#input_teleport_session_recording) | Setting for configuring session recording in Teleport. Check the [official documentation](https://gravitational.com/teleport/docs/admin-guide/#configuration) for more info | `string` | `"node"` | no |
| <a name="input_teleport_subdomain"></a> [teleport_subdomain](#input_teleport_subdomain) | DNS subdomain that will be created for the teleport server | `string` | `"teleport"` | no |
| <a name="input_teleport_version"></a> [teleport_version](#input_teleport_version) | Teleport version to use. Will be used to search for a compatible AMI if `ami_id` is `null`. If not set, will search for the newest AMI | `string` | `null` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_teleport_cluster_name"></a> [teleport_cluster_name](#output_teleport_cluster_name) | Name of the teleport cluster |
| <a name="output_teleport_server_fqdn"></a> [teleport_server_fqdn](#output_teleport_server_fqdn) | FQDN of the DNS record of the Teleport server. |
| <a name="output_teleport_server_instance_id"></a> [teleport_server_instance_id](#output_teleport_server_instance_id) | Instance id of the Teleport server. |
| <a name="output_teleport_server_instance_profile_arn"></a> [teleport_server_instance_profile_arn](#output_teleport_server_instance_profile_arn) | Instance profile ARN of the Teleport server. |
| <a name="output_teleport_server_instance_profile_id"></a> [teleport_server_instance_profile_id](#output_teleport_server_instance_profile_id) | Instance profile id of the Teleport server. |
| <a name="output_teleport_server_instance_profile_name"></a> [teleport_server_instance_profile_name](#output_teleport_server_instance_profile_name) | Instance profile name of the Teleport server. |
| <a name="output_teleport_server_private_ip"></a> [teleport_server_private_ip](#output_teleport_server_private_ip) | Private IP of the Teleport server. |
| <a name="output_teleport_server_public_ip"></a> [teleport_server_public_ip](#output_teleport_server_public_ip) | Public IP of the Teleport server. |
| <a name="output_teleport_server_role_arn"></a> [teleport_server_role_arn](#output_teleport_server_role_arn) | Role ARN of the Teleport server. |
| <a name="output_teleport_server_role_id"></a> [teleport_server_role_id](#output_teleport_server_role_id) | Role id of the Teleport server. |
| <a name="output_teleport_server_role_name"></a> [teleport_server_role_name](#output_teleport_server_role_name) | Role name of the Teleport server. |
| <a name="output_teleport_server_sg_id"></a> [teleport_server_sg_id](#output_teleport_server_sg_id) | Security group id of the Teleport server. |

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
