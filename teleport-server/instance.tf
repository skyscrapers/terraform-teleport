module "is_ebs_optimised" {
  source        = "github.com/skyscrapers/terraform-instances//is_ebs_optimised?ref=2.3.5"
  instance_type = var.instance_type
}

resource "aws_instance" "teleport_instance" {
  ami                         = length(var.ami_id) > 0 ? var.ami_id : join("", data.aws_ami.teleport_ami.*.image_id)
  instance_type               = var.instance_type
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.profile.id
  vpc_security_group_ids      = [aws_security_group.teleport_server.id]
  subnet_id                   = var.subnet_id
  disable_api_termination     = "false"
  ebs_optimized               = module.is_ebs_optimised.is_ebs_optimised
  associate_public_ip_address = "true"
  user_data                   = data.template_cloudinit_config.teleport.rendered

  root_block_device {
    volume_type           = var.root_vl_type
    volume_size           = var.root_vl_size
    delete_on_termination = var.root_vl_delete
  }

  tags = {
    Name        = "teleport-${var.project}-${var.environment}"
    Stack       = "teleport"
    Project     = var.project
    Environment = var.environment
  }
}

resource "aws_eip" "teleport_public" {
  instance = aws_instance.teleport_instance.id
  vpc      = true
}

data "template_cloudinit_config" "teleport" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content      = data.template_file.cloudinit_teleport.rendered
  }
}

data "template_file" "cloudinit_teleport" {
  template = file("${path.module}/templates/cloud-init.yaml.tpl")

  vars = {
    letsencrypt_email        = var.letsencrypt_email
    teleport_domain_name     = local.teleport_domain_name
    teleport_log_output      = var.teleport_log_output
    teleport_log_severity    = var.teleport_log_severity
    teleport_dynamodb_region = data.aws_region.current.name
    teleport_dynamodb_table  = local.teleport_dynamodb_table
    teleport_auth_tokens = length(var.teleport_auth_tokens) > 0 ? indent(
      6,
      join(
        "\n",
        concat(["tokens:"], formatlist("- %s", var.teleport_auth_tokens)),
      ),
    ) : ""
    teleport_cluster_name         = local.teleport_cluster_name
    teleport_session_recording    = var.teleport_session_recording
    acme_server                   = var.acme_server
    recorded_sessions_bucket_name = aws_s3_bucket.sessions.id
    project                       = var.project
    environment                   = var.environment
    instance_type                 = var.instance_type
  }
}
