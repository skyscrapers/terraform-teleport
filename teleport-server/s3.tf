resource "aws_s3_bucket" "sessions" {
  bucket = "teleport-sessions-${var.project}-${var.environment}"
  acl    = "private"

  tags = {
    Name        = "teleport-sessions-${var.project}-${var.environment}"
    Environment = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "sessions" {
  bucket                  = aws_s3_bucket.sessions.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
