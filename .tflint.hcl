# TFLint configuration for Terraform code quality
# https://github.com/terraform-linters/tflint

config {
  module = true
  force = false
}

plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

# AWS-specific rules
rule "aws_resource_missing_tags" {
  enabled = true
  tags = ["Environment", "ManagedBy"]
}

# Terraform rules
rule "terraform_naming_convention" {
  enabled = true
}

rule "terraform_documented_outputs" {
  enabled = true
}

rule "terraform_documented_variables" {
  enabled = true
}

rule "terraform_typed_variables" {
  enabled = true
}

rule "terraform_required_version" {
  enabled = true
}

rule "terraform_required_providers" {
  enabled = true
}

rule "terraform_unused_declarations" {
  enabled = true
}

rule "terraform_deprecated_index" {
  enabled = true
}

rule "terraform_comment_syntax" {
  enabled = true
}

rule "terraform_module_pinned_source" {
  enabled = true
}
