locals {
  cloudfront_uri = "https://${aws_cloudfront_distribution.spa.domain_name}"
  origin_id = "${local.namespace}-origin"
}

resource "aws_cloudfront_origin_access_identity" "spa_origin_identity" {
  comment = "SPA Origin access identity"
}

resource "aws_cloudfront_distribution" "spa" {
  enabled = true
  default_root_object = "index.html"

  default_cache_behavior {
    target_origin_id = local.origin_id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl = 0
    default_ttl = 1000
    max_ttl = 86400

    allowed_methods = [
      "GET",
      "DELETE",
      "PATCH",
      "POST",
      "PUT",
      "HEAD",
      "OPTIONS"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    forwarded_values {
      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  origin {
    domain_name = aws_s3_bucket.spa.bucket_regional_domain_name
    origin_id = local.origin_id

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.spa_origin_identity.cloudfront_access_identity_path
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = local.tags
}