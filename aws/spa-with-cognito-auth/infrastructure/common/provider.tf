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

provider "random" {
  version = "=2.3.0"
}

provider "archive" {
  version = "=1.3.0"
}

provider "time" {
  version = "=0.5.0"
}