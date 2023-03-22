module "acm" {
  source      = "terraform-aws-modules/acm/aws"
  version     = "~> v2.0"
  domain_name = var.domain
  zone_id     = aws_route53_zone.zone.zone_id
  subject_alternative_names = [
    "*.${var.domain}"
  ]
  tags = {
    Name        = "${var.project}-${var.environment}-cloudfront-cert"
    Environment = var.environment
    Deployment  = "Terraform"
  }

  providers = {
    aws = aws.us_east_1 # cloudfront needs acm certificate to be from "us-east-1" region
  }
}

# S3 bucket for CloudFront logs
resource "aws_s3_bucket" "cloudfront_logs" {
  bucket = "${var.project}-${var.environment}-cloudfront-logs"

  tags = {
    Name        = "${var.project}-${var.environment}-cloudfront-logs"
    Environment = var.environment
    Deployment  = "Terraform"
  }
}

resource "aws_s3_bucket_acl" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "cloudfront_logs" {
  bucket = aws_s3_bucket.cloudfront_logs.bucket
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "cloudfront_logs" {
  depends_on = [aws_s3_bucket_versioning.cloudfront_logs]
  bucket     = aws_s3_bucket.cloudfront_logs.bucket

  rule {
    id = "delete"
    noncurrent_version_expiration {
      noncurrent_days = 7
    }

    status = "Enabled"
  }
}

resource "aws_cloudfront_distribution" "cloudfront" {

  origin {
    connection_attempts = 3
    connection_timeout  = 10
    domain_name         = aws_s3_bucket_website_configuration.static_assets.website_endpoint
    origin_id           = "${var.project}-${var.environment}-public"

    custom_origin_config {
      http_port                = 80
      https_port               = 443
      origin_keepalive_timeout = 5
      origin_protocol_policy   = "http-only"
      origin_read_timeout      = 30
      origin_ssl_protocols = [
        "TLSv1.2",
      ]
    }
  }

  enabled         = true
  is_ipv6_enabled = true
  comment         = var.domain

  aliases = [var.domain, "client.${var.domain}", "api.${var.domain}"]

  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.cloudfront_logs.bucket_domain_name
  }

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = "${var.project}-${var.environment}-public"

    forwarded_values {
      query_string = true
      headers      = ["*"]

      cookies {
        forward = "all"
      }

    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 0
    max_ttl                = 0
    compress               = true
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/public/*"
    target_origin_id = "${var.project}-${var.environment}-public"

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }

    allowed_methods = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  price_class = var.cf_price_class

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = module.acm.this_acm_certificate_arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  # By default, cloudfront caches error for five minutes. There can be situation when a developer has accidentally broken the website and you would not want to wait for five minutes for the error response to be cached.
  # https://docs.aws.amazon.com/AmazonS3/latest/dev/CustomErrorDocSupport.html
  custom_error_response {
    error_code            = 400
    error_caching_min_ttl = var.error_ttl
  }

  custom_error_response {
    error_code            = 403
    error_caching_min_ttl = var.error_ttl
  }

  custom_error_response {
    error_code            = 404
    error_caching_min_ttl = var.error_ttl
  }

  custom_error_response {
    error_code            = 405
    error_caching_min_ttl = var.error_ttl
  }

  tags = {
    Name        = "${var.project}-${var.environment}-cloudfront"
    Environment = var.environment
    Deployment  = "Terraform"
  }
}