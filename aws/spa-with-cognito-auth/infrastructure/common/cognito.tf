data "template_file" "cognito_iam_assume_role_policy" {
  template = file("../iam/policies/assume-role/cognito-identity.json")

  vars = {
    cognito_identity_pool_id = aws_cognito_identity_pool.identity_pool.id
  }
}

resource "aws_iam_role" "identity_role" {
  name = "${local.namespace}-identity-role"

  assume_role_policy = data.template_file.cognito_iam_assume_role_policy.rendered
}

resource "aws_cognito_user_pool" "user_pool" {
  name = "${local.namespace}-cognito-user-pool"

  alias_attributes = [
    "email",
    "preferred_username"
  ]

  auto_verified_attributes = [
    "email"
  ]

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

  schema {
    attribute_data_type = "String"
    name = "email"
    mutable = false
    required = true
  }
}

resource "aws_cognito_user_pool_client" "spa_app_client" {
  name = "${local.namespace}-client"
  user_pool_id = aws_cognito_user_pool.user_pool.id
  refresh_token_validity = var.refresh_token_duration_in_days

  allowed_oauth_flows = [
    "implicit",
    "client_credentials",
    "code"
  ]

  allowed_oauth_scopes = [
    "email",
    "openid",
    "profile"
  ]

  callback_urls = [
    "http://localhost:3000/.auth/callback"
  ]

  explicit_auth_flows = [
    "USER_PASSWORD_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH",
    "ALLOW_USER_PASSWORD_AUTH",
    "ALLOW_REFRESH_TOKEN_AUTH"
  ]

  depends_on = [
    aws_cognito_user_pool.user_pool
  ]
}

resource "aws_cognito_identity_pool" "identity_pool" {
  identity_pool_name = "${var.app}${var.env}identityppol"
  developer_provider_name = "${local.namespace}provider"

  allow_unauthenticated_identities = false

  cognito_identity_providers {
    client_id = aws_cognito_user_pool_client.spa_app_client.id
    server_side_token_check = true

    provider_name = "cognito-idp.${var.region}.amazonaws.com/${aws_cognito_user_pool.user_pool.id}"
  }
}

resource "aws_cognito_identity_pool_roles_attachment" "identity_role_attachment" {
  identity_pool_id = aws_cognito_identity_pool.identity_pool.id

  roles = {
    "authenticated" = aws_iam_role.identity_role.id
  }
}