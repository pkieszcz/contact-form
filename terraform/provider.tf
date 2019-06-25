terraform {
  required_version = ">= 0.11.13, < 0.12"
}

provider "aws" {
  version                 = "2.16"
  region                  = "${var.aws_region}"
  shared_credentials_file = "${pathexpand("~/.aws/credentials")}"
  profile                 = "${var.aws_profile}"
}

data "aws_caller_identity" "current" {}
