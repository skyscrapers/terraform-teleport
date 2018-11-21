
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| additional_labels | List of additional labels to add to the Teleport node. Every list item represents a label, with its key and value. Example: `["k8s_version: 1.10.10", "instance_type: t2.medium"]` | list | `<list>` | no |
| auth_server | Auth server that this node will connect to, including the port number | string | - | yes |
| auth_token | Auth token that this node will present to the auth server. | string | - | yes |
| environment | Environment where this node belongs to, will be the third part of the node name. | string | `` | no |
| function | Function that this node performs, will be the first part of the node name. | string | - | yes |
| include_instance_id | If running in EC2, also include the instance ID in the node name. This is needed in autoscaled environments, so nodes don't collide with each other if they get recycled/autoscaled. | string | `true` | no |
| project | Project where this node belongs to, will be the second part of the node name. | string | `` | no |
| service_type | Type of service to use for Teleport. Either systemd or upstart | string | `systemd` | no |

## Outputs

| Name | Description |
|------|-------------|
| teleport_bootstrap_script |  |
| teleport_config_cloudinit |  |
| teleport_service_cloudinit |  |

