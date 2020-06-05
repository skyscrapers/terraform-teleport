resource "aws_cloudwatch_log_group" "teleport" {
  name              = "teleport_log_${var.project}_${var.environment}"
  retention_in_days = "30"

  tags = {
    Environment = var.environment
    Project     = var.project
    Application = "Teleport"
  }
}

resource "aws_cloudwatch_log_group" "teleport_audit" {
  name              = "teleport_audit_log_${var.project}_${var.environment}"
  retention_in_days = "30"

  tags = {
    Environment = var.environment
    Project     = var.project
    Application = "Teleport"
  }
}
