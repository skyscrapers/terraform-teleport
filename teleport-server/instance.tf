resource "aws_instance" "teleport_instance" {
  ami                         = coalesce(var.ami_id, join("", data.aws_ami.teleport_ami.*.image_id))
  instance_type               = var.instance_type
  key_name                    = var.key_name
  iam_instance_profile        = aws_iam_instance_profile.profile.id
  vpc_security_group_ids      = [aws_security_group.teleport_server.id]
  subnet_id                   = var.subnet_id
  disable_api_termination     = "false"
  ebs_optimized               = var.instance_ebs_optimized
  associate_public_ip_address = "true"
  user_data                   = data.cloudinit_config.teleport.rendered

  root_block_device {
    volume_type           = var.root_vl_type
    volume_size           = var.root_vl_size
    delete_on_termination = var.root_vl_delete
    encrypted             = var.root_vl_encrypted
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

data "cloudinit_config" "teleport" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/cloud-config"
    content = templatefile("${path.module}/templates/cloud-init.yaml.tpl", {
      letsencrypt_email             = var.letsencrypt_email
      teleport_domain_name          = local.teleport_domain_name
      teleport_log_output           = var.teleport_log_output
      teleport_log_severity         = var.teleport_log_severity
      teleport_dynamodb_region      = data.aws_region.current.name
      teleport_dynamodb_table       = local.teleport_dynamodb_table
      teleport_auth_tokens          = jsonencode(var.teleport_auth_tokens)
      teleport_cluster_name         = local.teleport_cluster_name
      teleport_session_recording    = var.teleport_session_recording
      recorded_sessions_bucket_name = aws_s3_bucket.sessions.id
      project                       = var.project
      environment                   = var.environment
      instance_type                 = var.instance_type
      audit_log_group_name          = aws_cloudwatch_log_group.teleport_audit.name
      teleport_log_group_name       = aws_cloudwatch_log_group.teleport.name
    })
  }
}
