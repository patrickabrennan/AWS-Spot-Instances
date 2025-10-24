terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.96.0, < 6.0.0"
    }
  }
}

provider "aws" {
  region = var.region
}

