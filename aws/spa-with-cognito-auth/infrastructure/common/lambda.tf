// We are going to leverage terraform to zip up our lambda application. The advantage here is that terraform
// will compute the sha of the zip file, which is used as the "etag" attribute when uploaded to S3. The etag
// value will trigger lambda to pickup that a new version has been deployed.
data "archive_file" "lambda_package" {
  type = "zip"
  output_path = var.lambda_api_output
  source_dir = var.lambda_api_source_dir
}

// We are using this in place of a version number. This is appended to the zip file that is uploaded to S3.
// Many people will opt for passing a version number in as a parameter.
resource "time_static" "lambda" {
}

// We can leverage terraform to upload our zipped up lambda application to S3. Here we are using the same bucket that
// stores our react app, which may not be preferable.
resource "aws_s3_bucket_object" "lambda_api_code" {
  bucket = aws_s3_bucket.spa.id
  source = data.archive_file.lambda_package.output_path

  // The key includes the date/time of the deployment
  key = "${local.namespace}-lambda-code-${time_static.lambda.rfc3339}.zip"

  // Etag can be used to let terraform know that it needs to upload the new version.
  etag = data.archive_file.lambda_package.output_base64sha256
}

// We need to have terraform create the lambda function so that our lambda application will actually run.
// NOTICE: We are using the same sha value as the source code hash. This is how lambda knows when it needs to
// pull the new code
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
