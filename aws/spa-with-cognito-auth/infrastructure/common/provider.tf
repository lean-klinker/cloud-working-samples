terraform {
  required_version = "=0.12.28"
}

provider "aws" {
  version = "=2.69.0"
  region = var.region
}

provider "template" {
  version = "2.1.2"
}