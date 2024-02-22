terraform {
  required_version = "~> 1.0"

  required_providers {
    aws = {
      source                = "hashicorp/aws"
      configuration_aliases = [aws.route53]
      version               = ">= 4.0"
    }
  }
}
