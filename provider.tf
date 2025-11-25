terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "6.21.0"
    }
  }
}

provider "aws" {
  region = var.region
}

terraform {
  backend "s3" {
    bucket         = "php-bucket1100"
    key            = "production/terraform.tfstate"
    region         = "us-east-1"
   # dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
