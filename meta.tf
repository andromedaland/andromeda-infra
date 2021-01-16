terraform {
  required_version = ">= 0.14"
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
  backend "s3" {
    key    = "terraform.tfstate"
    region = "us-east-1"
  }
}

provider "aws" {
  region = var.region
}

provider "aws" {
  region  = var.region
  profile = "andromeda-staging"
  alias   = "staging"
}

resource "random_uuid" "this" {}
data "aws_caller_identity" "this" {}

locals {
  prefix     = "andromeda"
  short_uuid = substr(random_uuid.this.result, 0, 8)
  tags = {
    "deno.land/x:environment"    = var.env
    "deno.land/x:uuid"           = local.short_uuid
    "deno.land/x:provisioned-by" = reverse(split(":", data.aws_caller_identity.this.arn))[0]
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "${local.prefix}-terraform-state-${local.short_uuid}"
  acl    = "private"
  tags   = local.tags
  versioning {
    enabled = true
  }
}

resource "aws_s3_bucket_public_access_block" "terraform_state_public_access" {
  bucket                  = aws_s3_bucket.terraform_state.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "state" {
  name         = "${local.prefix}-terraform-lock-${local.short_uuid}"
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.tags
}
