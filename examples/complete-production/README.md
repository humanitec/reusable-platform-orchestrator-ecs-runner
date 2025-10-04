# Complete Production Example

This example demonstrates a complete production-ready deployment of the ECS Runner module with all enterprise features enabled.

## Features Included

- **KMS Encryption**: Custom KMS key for encrypting S3 bucket and CloudWatch Logs
- **Network Security**: Security group with restrictive egress rules
- **IAM Best Practices**: Role path organization and permissions boundary support
- **Monitoring**: CloudWatch alarms for S3 bucket size
- **Alerting**: SNS topic for alarm notifications
- **Compliance**: Comprehensive tagging strategy
- **Data Protection**: S3 versioning and force_destroy protection

## Prerequisites

- AWS Account with appropriate permissions
- Terraform >= 1.6.0
- VPC with private subnets
- Humanitec organization ID

## Usage

1. Copy `terraform.tfvars.example` to `terraform.tfvars`:
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   ```

2. Update `terraform.tfvars` with your values:
   ```hcl
   region           = "us-east-1"
   vpc_id           = "vpc-12345678"
   subnet_ids       = ["subnet-12345678", "subnet-87654321"]
   humanitec_org_id = "my-org-id"
   owner_email      = "platform-team@example.com"
   alarm_email      = "ops-team@example.com"
   ```

3. Initialize and apply:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```

## Outputs

After deployment, you'll receive:
- Runner ID
- Humanitec role ARN
- S3 bucket name
- ECS cluster name
- CloudWatch log group names
- KMS key ARN
- Security group ID
- SNS topic ARN

## Cost Estimate

Base monthly cost (excluding Fargate task execution):
- KMS Key: ~$1.10
- S3 Storage (100GB): ~$2.30
- CloudWatch Logs (90-day retention): ~$10-20
- SNS: ~$0.50
- **Total**: ~$15-25/month

Additional costs for Fargate task execution will vary based on usage.

## Security Considerations

- All data is encrypted at rest using KMS
- Private subnets are required
- Security group restricts outbound traffic
- S3 bucket has public access blocked
- IAM roles follow least privilege principle
- CloudWatch logs are encrypted and have retention policy

## Monitoring

The example includes:
- S3 bucket size alarm (alerts at 100GB)
- SNS topic for alarm notifications
- CloudWatch log groups for task and exec logs

You can extend this with additional alarms:
- Task failure rate
- CloudWatch log volume
- IAM authentication failures

## Compliance

This example implements controls for:
- SOC 2
- ISO 27001
- HIPAA (with proper KMS configuration)
- PCI DSS
- GDPR

## Customization

You can customize this example by:
- Adjusting log retention periods
- Modifying alarm thresholds
- Adding additional security group rules
- Implementing custom IAM policies
- Adding VPC endpoints for cost optimization

## Troubleshooting

If deployment fails:
1. Verify VPC and subnet IDs are correct
2. Ensure subnets have internet access (via NAT Gateway)
3. Check IAM permissions for Terraform
4. Verify Humanitec organization ID

For more help, see the main module's [README](../../README.md) and [SECURITY](../../SECURITY.md) documentation.
