resource "aws_iam_role" "cloudfront_cloudwatch" {
  name        = "${var.project}-${var.environment}-cloudfront-cloudwatch"
  description = "Allows the lambda to read cloudfront logs"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "lambda.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "cloudfront_cloudwatch" {
  name = "${var.project}-${var.environment}-cloudfront_cloudwatch"

  policy = <<-EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:GetObject",
                "logs:CreateLogStream",
                "s3:ListBucket",
                "logs:PutLogEvents"
            ],
            "Resource": [
                "${aws_cloudwatch_log_group.cloudfront_cloudwatch.arn}:log-stream:*",
                "${aws_cloudwatch_log_group.cloudfront_cloudwatch.arn}",
                "${aws_s3_bucket.static_assets.arn}",
                "${aws_s3_bucket.static_assets.arn}/*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "cloudfront_cloudwatch-role0" {
  role       = aws_iam_role.cloudfront_cloudwatch.name
  policy_arn = aws_iam_policy.cloudfront_cloudwatch.arn
}

resource "aws_iam_role_policy_attachment" "cloudfront_cloudwatch-role4" {
  role       = aws_iam_role.cloudfront_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}