terraform {
  required_providers {
    aws = {
      configuration_aliases = [aws.dest, aws.source]
      source                = "hashicorp/aws"
    }
  }
}

data "aws_caller_identity" "source" {
  provider = aws.source
}

data "aws_caller_identity" "dest" {
  provider = aws.dest
}
