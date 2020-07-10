terraform {
  backend "s3" {
    bucket = "spa-cognito-sample-dev"
    key = "terraform/state.tf"
    region = "us-east-1"
  }
}