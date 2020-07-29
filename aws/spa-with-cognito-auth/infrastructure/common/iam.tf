// We need to specify a policy that allows our lambda application to create and write to cloud watch.
// Without this our lambda application will not be able to log data to CloudWatch.
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

// This policy allows the generated CloudFront identity to get objects out of S3.
// If a policy isn't applied to the CloudFront identity CloudFront will show access denied errors.
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

// This specifies the policy that our lambda application will use.
resource "aws_iam_policy" "lambda_policy" {
  name = "${local.namespace}-lambda-policy"
  path = "/"
  policy = data.aws_iam_policy_document.lambda_s3_policy.json
}

// This specifies the role that our lambda application will run under.
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

// Here we are attaching the policy that allows writing to cloud watch to the role our lambda application will use.
// If the policy is not attached the lambda appliation will not log to CloudWatch.
resource "aws_iam_role_policy_attachment" "lambda_policy_attachment" {
  policy_arn = aws_iam_policy.lambda_policy.arn
  role = aws_iam_role.lambda_assume_role_policy.name
}
