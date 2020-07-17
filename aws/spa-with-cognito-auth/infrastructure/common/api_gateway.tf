resource "aws_api_gateway_rest_api" "gateway" {
  name = "${local.namespace}-lambda-rest"
  description = "Sample API for securing lambdas"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  name          = "${local.namespace}-cognito-authorizer"
  type          = "COGNITO_USER_POOLS"
  provider_arns = [
    aws_cognito_user_pool.spa.arn
  ]
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part = "{proxy+}"
}

resource "aws_api_gateway_method" "options_proxy" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_options" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.options_proxy.http_method
  // The integration method for lambdas is always POST
  // The HTTP Method used to trigger the api gateway will be used for identifying which express route to hit.
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = aws_api_gateway_method.proxy.http_method
  // The integration method for lambdas is always POST
  // The HTTP Method used to trigger the api gateway will be used for identifying which express route to hit.
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_api_gateway_method" "root_options" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_rest_api.gateway.root_resource_id
  http_method = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_options_root" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_method.root_options.resource_id
  http_method = aws_api_gateway_method.root_options.http_method
  // The integration method for lambdas is always POST
  // The HTTP Method used to trigger the api gateway will be used for identifying which express route to hit.
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_api_gateway_method" "root" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_rest_api.gateway.root_resource_id
  http_method = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_method.root.resource_id
  http_method = aws_api_gateway_method.root.http_method
  // The integration method for lambdas is always POST
  // The HTTP Method used to trigger the api gateway will be used for identifying which express route to hit.
  integration_http_method = "POST"
  type = "AWS_PROXY"
  uri = aws_lambda_function.api_lambda.invoke_arn
}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  stage_name = var.env

  // Using the timestamp here to make sure that the api is deployed each time terraform is applied
  stage_description = "Stage deployed at ${timestamp()}"

  depends_on = [
    aws_api_gateway_integration.lambda,
    aws_api_gateway_integration.lambda_root,
    aws_api_gateway_integration.lambda_options,
    aws_api_gateway_integration.lambda_options_root
  ]
}

resource "aws_lambda_permission" "lambda_api_gateway_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal = "apigateway.amazonaws.com"
  statement_id = "AllowLambdaExecutionFromApiGateway"
  source_arn = "${aws_api_gateway_rest_api.gateway.execution_arn}/*/*"

  depends_on = [
    aws_lambda_function.api_lambda
  ]
}