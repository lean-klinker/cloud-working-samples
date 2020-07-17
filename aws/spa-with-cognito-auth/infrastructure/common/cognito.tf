locals {
  cognito_user_pool_uri = "https://${aws_cognito_user_pool_domain.spa.domain}.auth.${var.region}.amazoncognito.com"
  cognito_oidc_metadata_uri = "https://${aws_cognito_user_pool.spa.endpoint}/.well-known/openid-configuration"
  standard_oauth_scopes = [
    "email",
    "openid",
    "profile",
    "aws.cognito.signin.user.admin"
  ]
}

resource "random_integer" "spa_domain_postfix" {
  min = 0
  max = 50000

  keepers = {
    user_pool_arn = aws_cognito_user_pool.spa.arn
  }
}

resource "aws_cognito_user_pool" "spa" {
  name = "${local.namespace}-cognito-user-pool"

  tags = local.tags

  auto_verified_attributes = ["email"]
  username_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = false
  }

  username_configuration {
    case_sensitive = false
  }


  password_policy {
    minimum_length = 8
    require_lowercase = true
    require_numbers = true
    require_symbols = true
    require_uppercase = true
    temporary_password_validity_days = var.temp_password_validity_in_days
  }
}

resource "aws_cognito_user_pool_client" "spa_app_client" {
  name = "${local.namespace}-client"
  user_pool_id = aws_cognito_user_pool.spa.id
  refresh_token_validity = var.refresh_token_duration_in_days
  allowed_oauth_flows_user_pool_client = true

  supported_identity_providers = [
    "COGNITO"
  ]

  allowed_oauth_flows = [
    "code",
    "implicit"
  ]

  allowed_oauth_scopes = concat(
    local.standard_oauth_scopes,
    aws_cognito_resource_server.lambda_api.scope_identifiers
  )

  default_redirect_uri = "https://${aws_cloudfront_distribution.spa.domain_name}/.auth/callback"

  callback_urls = [
    "https://${aws_cloudfront_distribution.spa.domain_name}/.auth/callback",
    "http://localhost:3000/.auth/callback"
  ]

  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  read_attributes = var.spa_client_read_attributes

  depends_on = [
    aws_cognito_user_pool.spa
  ]
}

resource "aws_cognito_identity_pool" "spa" {
  identity_pool_name = "${var.app}${var.env}identityppol"
  developer_provider_name = "${local.namespace}provider"

  allow_unauthenticated_identities = false

  tags = local.tags

  cognito_identity_providers {
    client_id = aws_cognito_user_pool_client.spa_app_client.id
    server_side_token_check = true

    provider_name = "cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.spa.id}"
  }
}

resource "aws_cognito_user_pool_domain" "spa" {
  user_pool_id = aws_cognito_user_pool.spa.id
  domain = "${local.namespace}-${random_integer.spa_domain_postfix.result}"
}

resource "aws_cognito_resource_server" "lambda_api" {
  name = "${local.namespace}-lambda-api"
  identifier = "${local.namespace}-resource"
  user_pool_id = aws_cognito_user_pool.spa.id

  scope {
    scope_description = "Read data from lambda api"
    scope_name = "read"
  }

  scope {
    scope_description = "Write data to lambda api"
    scope_name = "write"
  }
}