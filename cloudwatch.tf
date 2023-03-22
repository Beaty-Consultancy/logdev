resource "aws_cloudwatch_log_group" "cloudfront_cloudwatch" {
  name = "${var.project}-${var.environment}-cloudfront_cloudwatch"

  tags = {
    Environment = var.environment
  }
}

data "archive_file" "cloudfront_cloudwatch" {
  type        = "zip"
  output_path = "cloudfront_cloudwatch.zip"
  source_dir  = "cloudfront_cloudwatch.py"
}

resource "aws_lambda_function" "cloudfront_cloudwatch" {
  architectures = [
    "x86_64",
  ]
  function_name                  = "${var.project}-${var.environment}-cloudfront_cloudwatch"
  filename                       = data.archive_file.cloudfront_cloudwatch.output_path
  handler                        = "lambda_handler"
  layers                         = []
  memory_size                    = 512
  package_type                   = "Zip"
  publish                        = true
  reserved_concurrent_executions = -1
  role                           = aws_iam_role.cloudfront_cloudwatch.arn
  runtime                        = "python3.7"
  tags = {
    "Environment" = var.environment
  }
  timeout = 60


  environment {
    variables = {
      "CloudWatch_LogFormat"    = "cloudfront"
      "CloudWatch_LogGroup"     = aws_cloudwatch_log_group.cloudfront_cloudwatch.name
    }
  }

  ephemeral_storage {
    size = 512
  }

  timeouts {}

  tracing_config {
    mode = "PassThrough"
  }
}

resource "aws_lambda_alias" "cloudfront_cloudwatch" {
  name             = var.environment
  description      = aws_lambda_function.cloudfront_cloudwatch.function_name
  function_name    = aws_lambda_function.cloudfront_cloudwatch.arn
  function_version = "$LATEST"
}