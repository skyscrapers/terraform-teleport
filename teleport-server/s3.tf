resource "aws_s3_bucket" "sessions" {
  bucket = "teleport-sessions-${var.project}-${var.environment}"
  acl    = "private"

  tags {
    Name        = "teleport-sessions-${var.project}-${var.environment}"
    Environment = "${var.environment}"
  }
}
