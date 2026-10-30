terraform {
  required_version = ">= 1.11.4"

  backend "s3" {
    bucket = "terraform-lwplabs-olajide"
    key    = "lwplabs-iac-repo/terraform.tfstate"
    region = "us-east-1"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
