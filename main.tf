provider "aws" {
  allowed_account_ids = [ var.account_id ]
  assume_role {
    role_arn          = var.iam_arn
  }
  region = var.region
}

terraform {
  backend "s3" {}
}

data "aws_ami" "ubuntu-linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "owner-alias"
    values = ["amazon"]
  }

  filter {
    name   = "name"
    values = ["ubuntu-minimal/images/hvm-ssd/ubuntu-jammy-22.04-arm64-minimal*"]
  }
}

data "aws_organizations_organization" "current" {}

resource "random_string" "random" {
  length = 8
  numeric = false
  special = false
  upper = false
}
