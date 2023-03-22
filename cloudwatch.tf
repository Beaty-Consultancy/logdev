module "cloudfront-lambda" {
  source      = "dasmeta/modules/aws//modules/cloudfront-to-s3-to-cloudwatch"
  bucket_name = aws_s3_bucket.cloudfront_logs.id
  account_id  = data.aws_caller_identity.current.account_id
}