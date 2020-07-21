// Any module that needs to expose generated values can do so using output values.
output "spa_client_id" {
  value = aws_cognito_user_pool_client.spa_app_client.id
}

output "spa_cloud_front_distribution_id" {
  value = aws_cloudfront_distribution.spa.id
}