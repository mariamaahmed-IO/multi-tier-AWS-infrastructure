locals {
  name = "${var.project}-${var.env}"
}

# ─── S3 BUCKET FOR LOGS ─────────────────────────────────────────────
resource "aws_s3_bucket" "s3_logs" {
  bucket = "${local.name}-app-logs-${random_id.suffix.hex}"

  tags = {
    Name = "${local.name}-app-logs"
  }
}

# Random suffix to ensure globally unique bucket name
resource "random_id" "suffix" {
  byte_length = 4
}

# Block all public access
resource "aws_s3_bucket_public_access_block" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Enable versioning
resource "aws_s3_bucket_versioning" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

# Enable encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# Lifecycle rule — move old logs to cheaper storage
resource "aws_s3_bucket_lifecycle_configuration" "s3_logs" {
  bucket = aws_s3_bucket.s3_logs.id

  rule {
    id     = "archive-old-logs"
    status = "Enabled"
    filter {
      prefix = ""  # applies to all objects
    }

    transition {
      days          = 30
      storage_class = "STANDARD_IA"
    }

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}