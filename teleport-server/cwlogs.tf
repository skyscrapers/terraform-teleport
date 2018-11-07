resource "aws_cloudwatch_log_group" "teleport" {
  name              = "teleport_log"
  retention_in_days = "28"

  tags {
    Environment = "${var.environment}"
    Application = "Teleport"
  }
}

resource "aws_cloudwatch_log_group" "teleport_audit" {
  name              = "teleport_audit_log"
  retention_in_days = "28"

  tags {
    Environment = "${var.environment}"
    Application = "Teleport"
  }
}
