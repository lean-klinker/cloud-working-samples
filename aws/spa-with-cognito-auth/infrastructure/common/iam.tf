data "aws_iam_policy_document" "lambda_s3_policy" {
  statement {
    sid = "1"
    actions = [
      "s3:GetBucketLocation",
      "s3:ListBucket",
      "sqs:SendMessage",
      "sqs:GetQueueUrl",
      "sqs:ReceiveMessage",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      aws_s3_bucket.spa.arn,
      aws_cloudwatch_log_group.lambda.arn
    ]
  }
}

data "aws_iam_policy_document" "cloudfront_origin_policy" {
  statement {
    sid = "OnlyCloudfrontReadAccess"
    effect = "Allow"

    principals {
      identifiers = [
        aws_cloudfront_origin_access_identity.spa_origin_identity.iam_arn
      ]
      type = "AWS"
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${local.bucket_name}/*"
    ]
  }
}

resource "aws_iam_policy" "lambda_policy" {
  name = "${local.namespace}-lambda-policy"
  path = "/"
  policy = data.aws_iam_policy_document.lambda_s3_policy.json
}

resource "aws_iam_role" "lambda_assume_role_policy" {
  name = "${local.namespace}-lambda-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role = aws_iam_role.lambda_assume_role_policy.name
}
