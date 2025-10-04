# Basic Example

This example demonstrates the minimal configuration needed to deploy the ECS Runner module.

## Features

- Minimal configuration (only required variables)
- Automatic runner ID generation
- New ECS cluster creation
- Default encryption (AWS managed keys)
- 30-day CloudWatch log retention

## Usage

1. Create a `terraform.tfvars` file:
   ```hcl
   region           = "us-east-1"
   subnet_ids       = ["subnet-12345678", "subnet-87654321"]
   humanitec_org_id = "my-org-id"
   ```

2. Deploy:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Outputs

After deployment:
- Runner ID (auto-generated)
- Humanitec role ARN
- S3 bucket name
- ECS cluster name

## For Production

This basic example is suitable for development/testing. For production deployments, consider:
- Using the [complete-production](../complete-production) example
- Enabling KMS encryption
- Configuring security groups
- Setting up CloudWatch alarms
- Using IAM permissions boundaries
- Implementing comprehensive tagging

See the main [README](../../README.md) for more information.
