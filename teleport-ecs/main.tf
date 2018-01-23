resource "aws_cloudwatch_log_group" "teleport" {
  name              = "teleport_logs_${var.environment}_${var.project}"
  retention_in_days = "7"

  tags {
    Environment = "${var.environment}"
  }
}
