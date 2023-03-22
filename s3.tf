# static-assets
resource "aws_s3_bucket" "static_assets" {
  bucket = "${var.project}-${var.environment}-static-assets"

  tags = {
    Name        = "${var.project}-${var.environment}-static-assets"
    Environment = var.environment
    Deployment  = "Terraform"
  }
}

resource "aws_s3_bucket_acl" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "static-assets" {
  bucket = aws_s3_bucket.static_assets.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "static_assets" {
  bucket = aws_s3_bucket.static_assets.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "static-assets" {
  depends_on = [aws_s3_bucket_versioning.static_assets]
  bucket     = aws_s3_bucket.static_assets.bucket

  rule {
    id = "delete"
    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    status = "Enabled"
  }
}

resource "aws_s3_bucket_policy" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id
  policy = jsonencode(
    {
      Statement = [
        {
          Action    = "s3:GetObject"
          Effect    = "Allow"
          Principal = "*"
          Resource  = "${aws_s3_bucket.static_assets.arn}/*"
        },
      ]
      Version = "2012-10-17"
    }
  )
}

resource "aws_s3_bucket_website_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

resource "aws_s3_bucket_cors_configuration" "static_assets" {
  bucket = aws_s3_bucket.static_assets.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["*"]
  }
}