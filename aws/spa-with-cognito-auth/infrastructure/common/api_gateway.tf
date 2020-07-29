resource "aws_api_gateway_rest_api" "gateway" {
  name = "${local.namespace}-lambda-rest"
  description = "Sample API for securing lambdas"
}

resource "aws_api_gateway_authorizer" "cognito_authorizer" {
  rest_api_id   = aws_api_gateway_rest_api.gateway.id
  name          = "${local.namespace}-cognito-authorizer"
  type          = "COGNITO_USER_POOLS"

  provider_arns = [
    aws_cognito_user_pool.users.arn
  ]
}

// This configures the api gateway to forward all requests to the lambda application.
// The lambda is responsible for figuring out what to do with each route.
// NOTE: This resource is used for everything, but the root
resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  parent_id = aws_api_gateway_rest_api.gateway.root_resource_id
  path_part = "{proxy+}"
}

// Since our application is going to be called from a browser we need to allow unauthenticated OPTIONS requests
// to pass through our API Gateway.
resource "aws_api_gateway_method" "options_proxy" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "OPTIONS"
  authorization = "NONE"
}

// This setups the integration for OPTIONS requests to the lambda application. OPTIONS requests are used
// to verify cross origin resource sharring (CORS) is allowed from the browser.
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

// For http methods other than OPTIONS we need to setup a new method that specifies how the api gateway should
// handle all other http methods. All other methods utilize the COGNITO Authorizer setup earlier.
// This guarantees that all requests to the gateway have a valid JWT before executing the lambda.
resource "aws_api_gateway_method" "proxy" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_resource.proxy.id
  http_method = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  authorization_scopes = aws_cognito_resource_server.lambda_api.scope_identifiers

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

// This setups the integration for all non-OPTIONS http requests to the lambda application.
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

// This tells the api gateway that we want to have the root of our api gateway respond to requests.
resource "aws_api_gateway_method" "root_options" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_rest_api.gateway.root_resource_id // NOTICE: here we are using the root resource id of the api gateway itself.
  http_method = "OPTIONS"
  authorization = "NONE"
}

// We need to have the root resource respond to OPTIONS requests the same way that the proxied requests will.
// For OPTIONS calls we don't want to require authorization.
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

// We need to have the root resource respond to non-OPTIONS requests the same way that the proxied requests will.
// For non-OPTIONS requests we want to require authorization.
resource "aws_api_gateway_method" "root" {
  rest_api_id = aws_api_gateway_rest_api.gateway.id
  resource_id = aws_api_gateway_rest_api.gateway.root_resource_id
  http_method = "ANY"
  authorization = "COGNITO_USER_POOLS"
  authorizer_id = aws_api_gateway_authorizer.cognito_authorizer.id

  authorization_scopes = aws_cognito_resource_server.lambda_api.scope_identifiers

  request_parameters = {
    "method.request.path.proxy" = true
  }
}

// We need to setup an integration between the root resource and our lambda application.
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

// We want to deploy our api so that we can actually use it. Here the stage is set to the environment.
// NOTE: The use of a timestamp to force a deployment everytime terraform executes.
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

// We need to allow our API Gateawy to invoke our lambda application, without this our API Gateway will not
// be allowed to invoke functions on our lambda application.
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