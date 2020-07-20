data "archive_file" "lambda_package" {
  type = "zip"
  output_path = var.lambda_api_output
  source_dir = var.lambda_api_source_dir
}

resource "time_static" "lambda" {
}

resource "aws_s3_bucket_object" "lambda_api_code" {
  key = "${local.namespace}-lambda-code-${time_static.lambda.rfc3339}.zip"
  bucket = aws_s3_bucket.spa.id
  source = data.archive_file.lambda_package.output_path
  etag = data.archive_file.lambda_package.output_base64sha256
}

resource "aws_lambda_function" "api_lambda" {
  function_name = "${local.namespace}-api-lambda"
  role = aws_iam_role.lambda_assume_role_policy.arn
  handler = "lambda.handler"

  runtime = var.lambda_api_runtime

  s3_bucket = aws_s3_bucket.spa.bucket
  s3_key = aws_s3_bucket_object.lambda_api_code.id
  source_code_hash = data.archive_file.lambda_package.output_base64sha256

  tags = local.tags
}
