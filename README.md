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
