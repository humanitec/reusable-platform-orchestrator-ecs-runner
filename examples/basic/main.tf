# Basic example with minimal configuration
# This example demonstrates the simplest deployment

terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

# ECS Runner with minimal configuration
module "ecs_runner" {
  source = "../.."

  region           = var.region
  subnet_ids       = var.subnet_ids
  humanitec_org_id = var.humanitec_org_id
}
