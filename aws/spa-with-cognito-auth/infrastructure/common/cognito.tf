locals {
  // We can use locals to make it easy to use generated values that require a little manipulation.
  // Use locals to eliminate duplicating common string concatenations where possible.
  cognito_user_pool_uri = "https://${aws_cognito_user_pool_domain.spa.domain}.auth.${var.region}.amazoncognito.com"
  cognito_oidc_metadata_uri = "https://${aws_cognito_user_pool.users.endpoint}/.well-known/openid-configuration"
  standard_oauth_scopes = [
    "email",
    "openid",
    "profile",
    "aws.cognito.signin.user.admin"
  ]
}

// We need to have cognito setup for a custom domain. This random number avoids trying to use a domain name.
// That is not actually available.
resource "random_integer" "spa_domain_postfix" {
  min = 0
  max = 50000

  keepers = {
    user_pool_arn = aws_cognito_user_pool.users.arn
  }
}



// Create a user pool for authenticating users for our application.
resource "aws_cognito_user_pool" "users" {
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

// For our react app to be able to login users the react application needs to be registered as a application client with
// our Cognito user pool.
resource "aws_cognito_user_pool_client" "spa_app_client" {
  name = "${local.namespace}-client"
  user_pool_id = aws_cognito_user_pool.users.id
  refresh_token_validity = var.refresh_token_duration_in_days
  allowed_oauth_flows_user_pool_client = true

  supported_identity_providers = [
    "COGNITO"
  ]

  allowed_oauth_flows = [
    "code",
    "implicit"
  ]

  // Since our react application needs to get data from our lambda we need to allow the react application client
  // to use the scopes for our lambda api.
  allowed_oauth_scopes = concat(
    local.standard_oauth_scopes,
    aws_cognito_resource_server.lambda_api.scope_identifiers
  )

  default_redirect_uri = "https://${aws_cloudfront_distribution.spa.domain_name}/.auth/callback"

  // Here we are setting up CloudFront and our local application as valid callback urls.
  // NOTE: You will want to remove the local callback url for production deployments.
  callback_urls = [
    "https://${aws_cloudfront_distribution.spa.domain_name}/.auth/callback",
    "http://localhost:3000/.auth/callback"
  ]

  // We need to specify the allowed authentication flows for our application client.
  explicit_auth_flows = [
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  read_attributes = var.spa_client_read_attributes

  depends_on = [
    aws_cognito_user_pool.users
  ]
}

// We need to tell cognito to use itself as a valid identity provider. This seems odd, but since we aren't federating
// with another identity provider we need to tell Cognito that our react app client can use our user pool as an
// identity provider.
resource "aws_cognito_identity_pool" "spa" {
  identity_pool_name = "${var.app}${var.env}identityppol"
  developer_provider_name = "${local.namespace}provider"

  allow_unauthenticated_identities = false

  tags = local.tags

  cognito_identity_providers {
    client_id = aws_cognito_user_pool_client.spa_app_client.id
    server_side_token_check = true

    provider_name = "cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.users.id}"
  }
}

// To use the hosted login ui we need to have a custom domain. The domain name must be unique, which is why we are using
// a random number here. Unfortunately, we won't know the true domain until after deployment.
resource "aws_cognito_user_pool_domain" "spa" {
  user_pool_id = aws_cognito_user_pool.users.id
  domain = "${local.namespace}-${random_integer.spa_domain_postfix.result}"
}

// We need to register our lambda application as a resource server with Cognito. This allows us to specify scopes
// that are specific to our lambda application.
resource "aws_cognito_resource_server" "lambda_api" {
  name = "${local.namespace}-lambda-api"
  identifier = "${local.namespace}-resource"
  user_pool_id = aws_cognito_user_pool.users.id

  // Specify a custom scope that would allow reading data from the resource
  scope {
    scope_description = "Read data from lambda api"
    scope_name = "read"
  }

  // Specify a custom scope that would allow writing data to the resource
  scope {
    scope_description = "Write data to lambda api"
    scope_name = "write"
  }
}