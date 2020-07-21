locals {
  bucket_name = "${local.namespace}-spa"
  mime_types = {
    htm = "text/html"
    html = "text/html"
    css = "text/css"
    ttf = "font/ttf"
    ico = "image/x-icon"
    js = "application/javascript"
    json = "application/json"
    map = "application/javascript"
    png = "image/png"
    svg = "image/svg+xml"
    txt = "text/plain"
  }
}

// Here we are leveraging terraform's template file provider to generate our settings.json based on the infrastructure
// that is being deployed. This allows our settings.json to be generated correctly each time and be immediately
// available to the application on deployment.
data "template_file" "spa_settings_file" {
  template = file("../templates/spa/settings.json")

  vars = {
    spa_client_id = aws_cognito_user_pool_client.spa_app_client.id
    idp_authority = local.cognito_user_pool_uri
    idp_metadata_uri = local.cognito_oidc_metadata_uri
    spa_redirect_uri = "${local.cloudfront_uri}/.auth/callback",
    lambda_api_url = aws_api_gateway_deployment.api_deployment.invoke_url
    scope = join(" ", aws_cognito_user_pool_client.spa_app_client.allowed_oauth_scopes)
  }
}

// This is the S3 bucket that will hold our react application and lambda code.
resource "aws_s3_bucket" "spa" {
  bucket = local.bucket_name
  policy = data.aws_iam_policy_document.cloudfront_origin_policy.json

  website {
    index_document = "index.html"
  }
  tags = local.tags
}

// We can leverage terraform's for_each to upload each file in our react applications build folder.
// This will ensure that the correct files are uploaded AND that old files are removed from the bucket.
resource "aws_s3_bucket_object" "spa_content" {
  for_each = fileset(var.spa_output, "**/*.*")
  bucket = aws_s3_bucket.spa.bucket
  key = replace(each.value, var.spa_output, "")
  source = "${var.spa_output}/${each.value}"
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])
  etag = filemd5("${var.spa_output}/${each.value}")
  tags = local.tags
}

// Since terraform is responsible for generating our settings.json file based on the current infrastructure. We need
// to have terraform upload the generated settings.json file to our S3 bucket so that CloudFront can serve it to the
// react application.
resource "aws_s3_bucket_object" "settings_json" {
  bucket = aws_s3_bucket.spa.bucket
  key = "settings.json"
  content_base64 = base64encode(data.template_file.spa_settings_file.rendered)
  content_type = "application/json"
  etag = md5(data.template_file.spa_settings_file.rendered)
  tags = local.tags
}