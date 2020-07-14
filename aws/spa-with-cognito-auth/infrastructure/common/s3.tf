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

data "template_file" "spa_settings_file" {
  template = file("../templates/spa/settings.json")

  vars = {
    spa_client_id = aws_cognito_user_pool_client.spa_app_client.id
    idp_authority = local.cognito_user_pool_uri
    idp_metadata_uri = local.cognito_oidc_metadata_uri
    spa_redirect_uri = "${local.cloudfront_uri}/.auth/callback"
  }
}

data "template_file" "bucket_policy" {
  template = file("../templates/iam/policies/bucket_policy.json")

  vars = {
    bucket_name = local.bucket_name
    origin_access_identity_arn = aws_cloudfront_origin_access_identity.spa_origin_identity.iam_arn
  }
}

resource "aws_s3_bucket" "spa" {
  bucket = local.bucket_name
  policy = data.template_file.bucket_policy.rendered

  website {
    index_document = "index.html"
  }
  tags = local.tags
}

resource "aws_s3_bucket_object" "spa_content" {
  for_each = fileset(var.spa_output, "**/*.*")
  bucket = aws_s3_bucket.spa.bucket
  key = replace(each.value, var.spa_output, "")
  source = "${var.spa_output}/${each.value}"
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])

  tags = local.tags
}

resource "aws_s3_bucket_object" "settings_json" {
  bucket = aws_s3_bucket.spa.bucket
  key = "settings.json"
  content_base64 = base64encode(data.template_file.spa_settings_file.rendered)
  content_type = "application/json"

  tags = local.tags
}