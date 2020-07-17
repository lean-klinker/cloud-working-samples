resource "aws_api_gateway_rest_api" "lambda_api" {
  name = "${local.namespace}-lambda-rest"
  description = "Sample API for securing lambdas"
}

resource "aws_api_gateway_resource" "lambda_resource_proxy" {
  parent_id = aws_api_gateway_rest_api.lambda_api.root_resource_id
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  path_part = "{proxy+}"
}

//resource "aws_api_gateway_authorizer" "lambda_authorizer" {
//  name = "${local.namespace}-authorizer"
//  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
//  type = "COGNITO_USER_POOLS"
//
//  provider_arns = [
//    aws_cognito_user_pool.spa.arn
//  ]
//}

//resource "aws_api_gateway_method" "options_method" {
//  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
//  resource_id = aws_api_gateway_resource.lambda_resource.id
//  http_method = "OPTIONS"
//  authorization = "NONE"
//}
//
//resource "aws_api_gateway_method_response" "options_method_response" {
//  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
//  resource_id = aws_api_gateway_resource.lambda_resource.id
//  http_method = aws_api_gateway_method.options_method.http_method
//  status_code = "200"
//
//  response_models = {
//    "application/json" = "Empty"
//  }
//
//  response_parameters = {
//    "method.response.header.Access-Control-Allow-Headers" = true,
//    "method.response.header.Access-Control-Allow-Methods" = true,
//    "method.response.header.Access-Control-Allow-Origin" = true
//  }
//}
//
//resource "aws_api_gateway_integration" "options_integration" {
//  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
//  resource_id = aws_api_gateway_resource.lambda_resource.id
//  http_method = aws_api_gateway_method.options_method.http_method
//  type = "MOCK"
//
//  depends_on = [
//    aws_api_gateway_method.options_method
//  ]
//}
//
//resource "aws_api_gateway_integration_response" "options_integration_resposne" {
//  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
//  resource_id = aws_api_gateway_resource.lambda_resource.id
//  http_method = aws_api_gateway_method.options_method.http_method
//  status_code = aws_api_gateway_method_response.options_method_response.status_code
//
//  response_parameters = {
//    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
//    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE,PATCH'",
//    "method.response.header.Access-Control-Allow-Origin" = "'*'"
//  }
//
//  depends_on = [
//    aws_api_gateway_method_response.options_method_response
//  ]
//}

resource "aws_api_gateway_method" "lambda_proxy_method" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.lambda_resource_proxy.id
  http_method = "ANY"
  authorization = "NONE"

//  authorization = "COGNITO_USER_POOLS"
//  authorizer_id = aws_api_gateway_authorizer.lambda_authorizer.id
//
//  authorization_scopes = [
//    join(" ", aws_cognito_resource_server.lambda_api.scope_identifiers)
//  ]
}

resource "aws_api_gateway_method_response" "lambda_method_proxy_response" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.lambda_resource_proxy.id
  http_method = aws_api_gateway_method.lambda_proxy_method.http_method
  status_code = "200"

  depends_on = [
    aws_lambda_function.api_lambda
  ]
}

resource "aws_api_gateway_integration" "lambda_proxy_integration" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.lambda_resource_proxy.id
  http_method = aws_api_gateway_method.lambda_proxy_method.http_method
  uri = aws_lambda_function.api_lambda.invoke_arn
  type = "AWS_PROXY"

  // The integration method for lambdas is always POST
  // The HTTP Method used to trigger the api gateway will be used for identifying which express route to hit.
  integration_http_method = "POST"

  depends_on = [
    aws_api_gateway_method.lambda_proxy_method
  ]
}

resource "aws_api_gateway_integration_response" "lambda_proxy_integration_response" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  resource_id = aws_api_gateway_resource.lambda_resource_proxy.id
  http_method = aws_api_gateway_method.lambda_proxy_method.http_method
  status_code = aws_api_gateway_method_response.lambda_method_proxy_response.status_code


}

resource "aws_api_gateway_deployment" "api_deployment" {
  rest_api_id = aws_api_gateway_rest_api.lambda_api.id
  stage_name = var.env

  // Using the timestamp here to make sure that the api is deployed each time terraform is applied
  stage_description = "Stage deployed at ${timestamp()}"

  depends_on = [
    aws_api_gateway_integration.lambda_proxy_integration
  ]
}

resource "aws_lambda_permission" "lambda_api_gateway_permission" {
  action = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal = "apigateway.amazonaws.com"
  statement_id = "AllowLambdaExecutionFromApiGateway"
  source_arn = "${aws_api_gateway_rest_api.lambda_api.execution_arn}/*/*"

  depends_on = [
    aws_lambda_function.api_lambda
  ]
}