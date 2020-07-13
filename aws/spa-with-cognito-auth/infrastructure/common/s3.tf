locals {
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
    spa_redirect_uri = "${local.cloudfront_uri}/.auth/callback"
  }

  depends_on = [
    aws_cognito_user_pool_client.spa_app_client,
    aws_cloudfront_distribution.spa
  ]
}

resource "aws_s3_bucket" "spa" {
  bucket = "${local.namespace}-spa"

  acl = "private"
}

resource "aws_s3_bucket_object" "spa_content" {
  for_each = fileset(var.spa_output, "**/*.*")
  bucket = aws_s3_bucket.spa.bucket
  key = replace(each.value, var.spa_output, "")
  source = "${var.spa_output}/${each.value}"
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])

  depends_on = [
    aws_s3_bucket.spa
  ]
}

resource "aws_s3_bucket_object" "settings_json" {
  bucket = aws_s3_bucket.spa.bucket
  key = "settings.json"
  content_base64 = base64encode(data.template_file.spa_settings_file.rendered)
  content_type = "application/json"

  depends_on = [
    aws_s3_bucket.spa,
    aws_s3_bucket_object.spa_content
  ]
}