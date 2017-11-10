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
