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

resource "aws_s3_bucket" "spa_bucket" {
  bucket = "${local.namespace}-lambda-bucket"

  acl = "private"
}

resource "aws_s3_bucket_object" "web_app_content" {
  for_each = fileset(var.spa_output, "**/*.*")
  bucket = aws_s3_bucket.spa_bucket.bucket
  key = replace(each.value, var.spa_output, "")
  source = "${var.spa_output}${each.value}"
  content_type = lookup(local.mime_types, split(".", each.value)[length(split(".", each.value)) - 1])

  depends_on = [
    aws_s3_bucket.spa_bucket
  ]
}