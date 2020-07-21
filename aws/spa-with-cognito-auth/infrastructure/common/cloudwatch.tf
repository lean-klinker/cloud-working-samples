// CloudWatch is where our lambda application will write logs. We need to setup a log group for our lambda application.
resource "aws_cloudwatch_log_group" "lambda" {
  name = "/aws/lambda/${aws_lambda_function.api_lambda.function_name}"
  retention_in_days = 7
}