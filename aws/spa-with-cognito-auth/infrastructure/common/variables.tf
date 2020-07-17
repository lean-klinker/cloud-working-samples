variable "env" {
  type = string
}

variable "app" {
  type = string
  default = "sample"
}

variable "spa_output" {
  type = string
  default = "../../spa/build"
}

variable "lambda_api_output" {
  type = string
  default = "../../lambda/build.zip"
}

variable "lambda_api_source_dir" {
  type = string
  default = "../../lambda/build"
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "tags" {
  type = map(string)
  default = {}
}

variable "refresh_token_duration_in_days" {
  type = number
  default = 30
}

variable "temp_password_validity_in_days" {
  type = number
  default = 30
}

variable "spa_client_read_attributes" {
  type = list(string)
  default = [
    "address",
    "birthdate",
    "email",
    "email_verified",
    "family_name",
    "gender",
    "given_name",
    "locale",
    "middle_name",
    "name",
    "nickname",
    "phone_number",
    "phone_number_verified",
    "picture",
    "preferred_username",
    "profile",
    "zoneinfo",
    "updated_at",
    "website"
  ]
}

variable "lambda_api_runtime" {
  type = string
  default = "nodejs12.x"
}

locals {
  namespace = "${var.env}-${var.app}"
}