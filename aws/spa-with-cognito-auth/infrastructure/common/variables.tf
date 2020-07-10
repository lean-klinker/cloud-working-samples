variable "env" {
  type = string
}

variable "app" {
  type = string
}

variable "spa_output" {
  type = string
}

variable "spa_origin_id" {
  type = string
}

variable "region" {
  type = string
  default = "us-east-1"
}

variable "refresh_token_duration_in_days" {
  type = number
  default = 30
}

variable "temp_password_validity_in_days" {
  type = number
  default = 30
}

locals {
  namespace = "${var.env}-${var.app}"
}