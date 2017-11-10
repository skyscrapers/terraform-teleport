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
It'll create three different security groups: `auth`, `proxy` and `node`

### Available variables:
* [`vpc_id`]: String(required): The VPC where to put the security groups.
* [`cidr_blocks`]: List(optional): CIDR blocks from where to allow connections to the Teleport cluster. Defaults to ["0.0.0.0/0"]

### Output
 * [`auth_sg_id`]: String: Security Group id for auth.
 * [`proxy_sg_id`]: String: Security Group id for proxy.
 * [`node_sg_id`]: String: Security Group id for node.

### Example
```
module "security_groups_teleport" {
  source = "github.com/skyscrapers/terraform-teleport//teleport-security-groups?ref=1.0.0"
  vpc_id = "${module.vpc.vpc_id}"
}
```
