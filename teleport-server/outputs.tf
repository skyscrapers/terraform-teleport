output "teleport_server_sg_id" {
  description = "Security group id of the Teleport server."
  value       = aws_security_group.teleport_server.id
}

output "teleport_server_instance_id" {
  description = "Instance id of the Teleport server."
  value       = aws_instance.teleport_instance.id
}

output "teleport_server_public_ip" {
  description = "Public IP of the Teleport server."
  value       = aws_eip.teleport_public.public_ip
}

output "teleport_server_private_ip" {
  description = "Private IP of the Teleport server."
  value       = aws_eip.teleport_public.private_ip
}

output "teleport_server_fqdn" {
  description = "FQDN of the DNS record of the Teleport server."
  value       = aws_route53_record.teleport.fqdn
}

output "teleport_cluster_name" {
  description = "Name of the teleport cluster"
  value       = local.teleport_cluster_name
}

output "teleport_server_instance_profile_id" {
  description = "Instance profile id of the Teleport server."
  value       = aws_iam_instance_profile.profile.id
}

output "teleport_server_instance_profile_arn" {
  description = "Instance profile ARN of the Teleport server."
  value       = aws_iam_instance_profile.profile.arn
}

output "teleport_server_instance_profile_name" {
  description = "Instance profile name of the Teleport server."
  value       = aws_iam_instance_profile.profile.name
}

output "teleport_server_role_id" {
  description = "Role id of the Teleport server."
  value       = aws_iam_role.role.unique_id
}

output "teleport_server_role_arn" {
  description = "Role ARN of the Teleport server."
  value       = aws_iam_role.role.arn
}

output "teleport_server_role_name" {
  description = "Role name of the Teleport server."
  value       = aws_iam_role.role.name
}
