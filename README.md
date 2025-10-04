# Reusable Platform Orchestrator ECS Runner

A reusable Terraform module for setting up an ECS Runner for the Humanitec Platform Orchestrator.

## Overview

This module provides a production-ready, enterprise-grade Terraform configuration for deploying an ECS-based runner that integrates with the Humanitec Platform Orchestrator. The module handles runner ID generation, AWS resource provisioning, IAM role configuration, and implements security best practices for enterprise environments.

### Key Features

- **Secure by Default**: OIDC authentication, encryption at rest, least privilege IAM policies
- **Enterprise Ready**: Support for permissions boundaries, KMS encryption, comprehensive logging
- **Cost Optimized**: S3 lifecycle policies, configurable log retention, Fargate Spot support
- **Compliance Focused**: Audit logging, encryption, versioning, and tagging support
- **Highly Available**: Multi-AZ support, automatic failover, Container Insights enabled
- **Well Documented**: Comprehensive security, architecture, and troubleshooting guides

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.6.0 |
| aws | >= 4.0 |
| random | >= 3.0 |
| platform-orchestrator | ~> 2.0 |

## Usage

### Basic Example

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region           = "us-east-1"
  subnet_ids       = ["subnet-12345678", "subnet-87654321"]
  humanitec_org_id = "my-org-id"
}
```

### With Custom Runner ID

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region           = "us-east-1"
  subnet_ids       = ["subnet-12345678", "subnet-87654321"]
  humanitec_org_id = "my-org-id"
  runner_id        = "my-custom-runner"
}
```

### With Custom Runner ID Prefix

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region           = "us-east-1"
  subnet_ids       = ["subnet-12345678", "subnet-87654321"]
  humanitec_org_id = "my-org-id"
  runner_id_prefix = "prod-runner"
}
```

### With Existing ECS Cluster

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region                    = "us-east-1"
  subnet_ids                = ["subnet-12345678", "subnet-87654321"]
  humanitec_org_id          = "my-org-id"
  existing_ecs_cluster_name = "existing-cluster"
}
```

### With Additional Tags

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region           = "us-east-1"
  subnet_ids       = ["subnet-12345678", "subnet-87654321"]
  humanitec_org_id = "my-org-id"
  
  additional_tags = {
    Environment = "production"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}
```

### With Subnets and Security Groups

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region             = "us-east-1"
  subnet_ids         = ["subnet-12345678", "subnet-87654321"]
  humanitec_org_id   = "my-org-id"
  security_group_ids = ["sg-12345678"]
}
```

### Production Configuration with KMS Encryption

```hcl
# Create a KMS key for encryption
resource "aws_kms_key" "runner" {
  description             = "KMS key for ECS runner encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "ecs-runner-key"
    Environment = "production"
  }
}

resource "aws_kms_alias" "runner" {
  name          = "alias/ecs-runner"
  target_key_id = aws_kms_key.runner.key_id
}

# Configure KMS key policy to allow CloudWatch Logs
resource "aws_kms_key_policy" "runner" {
  key_id = aws_kms_key.runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "Enable IAM User Permissions"
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "Allow CloudWatch Logs"
        Effect = "Allow"
        Principal = {
          Service = "logs.amazonaws.com"
        }
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:CreateGrant",
          "kms:DescribeKey"
        ]
        Resource = "*"
        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ecs/*"
          }
        }
      }
    ]
  })
}

module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region           = "us-east-1"
  subnet_ids       = module.vpc.private_subnet_ids
  humanitec_org_id = "my-org-id"
  runner_id        = "prod-runner"
  
  # Security configurations
  enable_s3_encryption          = true
  kms_key_arn                   = aws_kms_key.runner.arn
  s3_bucket_versioning_enabled  = true
  s3_bucket_force_destroy       = false  # Prevent accidental deletion
  
  # Logging configurations
  cloudwatch_log_retention_days = 90
  
  # IAM configurations
  iam_role_path                 = "/platform/runners/"
  iam_role_permissions_boundary = "arn:aws:iam::123456789012:policy/EnterprisePermissionsBoundary"
  
  # Network configurations
  security_group_ids = [aws_security_group.ecs_tasks.id]
  
  # Tagging for governance
  additional_tags = {
    Environment        = "production"
    CostCenter         = "platform-engineering"
    DataClassification = "internal"
    ComplianceScope    = "sox"
    ManagedBy          = "terraform"
    Owner              = "platform-team@example.com"
  }
}
```

### Multi-Region Setup

```hcl
module "ecs_runner_us_east" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region           = "us-east-1"
  subnet_ids       = module.vpc_us_east.private_subnet_ids
  humanitec_org_id = "my-org-id"
  runner_id        = "us-east-runner"
  
  additional_tags = {
    Region = "us-east-1"
  }
}

module "ecs_runner_eu_west" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region           = "eu-west-1"
  subnet_ids       = module.vpc_eu_west.private_subnet_ids
  humanitec_org_id = "my-org-id"
  runner_id        = "eu-west-runner"
  
  additional_tags = {
    Region = "eu-west-1"
  }
}
```

## Variables

### Required Variables

| Name | Description | Type |
|------|-------------|------|
| region | The AWS region where resources will be created | `string` |
| subnet_ids | List of subnet IDs where ECS tasks will be launched (use private subnets for production) | `list(string)` |
| humanitec_org_id | The Humanitec organization ID for OIDC federation | `string` |

### Optional Variables

| Name | Description | Type | Default |
|------|-------------|------|---------|
| runner_id | The ID of the runner. If not provided, one will be generated | `string` | `null` |
| runner_id_prefix | The prefix to use when generating a runner ID | `string` | `"runner"` |
| existing_ecs_cluster_name | The name of an existing ECS cluster to use | `string` | `null` |
| security_group_ids | List of security group IDs to attach to ECS tasks | `list(string)` | `[]` |
| additional_tags | Additional tags to apply to all resources | `map(string)` | `{}` |
| enable_s3_encryption | Enable encryption for S3 bucket | `bool` | `true` |
| kms_key_arn | KMS key ARN for encrypting S3 and CloudWatch Logs | `string` | `null` |
| s3_bucket_versioning_enabled | Enable versioning for the S3 bucket | `bool` | `true` |
| s3_bucket_force_destroy | Allow destruction of S3 bucket with objects | `bool` | `false` |
| cloudwatch_log_retention_days | Number of days to retain CloudWatch logs | `number` | `30` |
| iam_role_path | Path for IAM roles | `string` | `"/"` |
| iam_role_permissions_boundary | ARN of permissions boundary policy for IAM roles | `string` | `null` |

## Outputs

| Name | Description |
|------|-------------|
| humanitec_role_arn | The ARN of the IAM role for Humanitec |
| execution_role_arn | The ARN of the ECS task execution role |
| task_role_arn | The ARN of the ECS task role |
| ecs_task_manager_role_arn | The ARN of the IAM role for managing ECS tasks |
| runner_id | The ID of the runner |
| s3_bucket | The name of the S3 bucket |
| ecs_cluster_name | The name of the ECS cluster |
| ecs_cluster_arn | The ARN of the ECS cluster |
| cloudwatch_log_group_name | The name of the CloudWatch log group for ECS tasks |
| cloudwatch_log_group_arn | The ARN of the CloudWatch log group for ECS tasks |
| cloudwatch_exec_log_group_name | The name of the CloudWatch log group for ECS Exec |
| cloudwatch_exec_log_group_arn | The ARN of the CloudWatch log group for ECS Exec |

## Security Best Practices

For production deployments, please review our comprehensive [Security Best Practices](SECURITY.md) guide, which covers:

- Encryption at rest (S3, CloudWatch Logs)
- IAM security (permissions boundaries, least privilege)
- Network security (VPC, security groups)
- Data protection (versioning, lifecycle policies)
- Compliance considerations
- Incident response procedures

## Architecture

For a detailed understanding of the module's architecture, component interactions, and data flows, see the [Architecture Documentation](ARCHITECTURE.md).

## Cost Estimation

### Base Costs (Monthly)

The following are approximate costs for running the ECS runner module:

| Component | Description | Estimated Cost |
|-----------|-------------|----------------|
| ECS Fargate | Depends on task execution (pay per use) | Variable |
| S3 Storage | Artifacts storage (~100 GB) | ~$2.30 |
| S3 Requests | API calls | ~$0.05 |
| CloudWatch Logs | Ingestion and storage (30-day retention) | ~$5-20 |
| Data Transfer | Outbound data transfer | Variable |
| KMS | Key storage and API requests | ~$1.10 |

**Total Base Cost**: ~$10-25/month (excluding Fargate task execution)

### Fargate Costs

Fargate costs depend on CPU and memory allocated and duration:
- **0.25 vCPU, 0.5 GB**: ~$0.012/hour
- **0.5 vCPU, 1 GB**: ~$0.024/hour
- **1 vCPU, 2 GB**: ~$0.049/hour

Use Fargate Spot for up to 70% cost savings on non-critical workloads.

### Cost Optimization Tips

1. **Use S3 Lifecycle Policies**: Automatically configured to transition old versions to cheaper storage
2. **Configure Log Retention**: Reduce CloudWatch log retention for non-production environments
3. **Use Fargate Spot**: Enable Spot capacity for cost-sensitive workloads
4. **Enable VPC Endpoints**: Reduce data transfer costs
5. **Monitor with AWS Cost Explorer**: Track costs by tags

## Troubleshooting

### Common Issues

#### Task Fails to Start
- **Symptom**: Tasks fail immediately after launch
- **Possible Causes**: 
  - No internet access from subnets (check NAT Gateway)
  - ECR permissions missing on execution role
  - Invalid container image reference
- **Resolution**: Check CloudWatch Logs in `/aws/ecs/{runner_id}` for detailed error messages

#### Authentication Errors
- **Symptom**: OIDC authentication fails
- **Possible Causes**:
  - Incorrect Humanitec organization ID
  - OIDC thumbprint mismatch
  - IAM role trust policy misconfigured
- **Resolution**: Verify OIDC configuration and trust policy conditions

#### S3 Access Denied
- **Symptom**: Tasks cannot read/write to S3 bucket
- **Possible Causes**:
  - Task role missing S3 permissions
  - KMS key policy doesn't allow task role
  - Bucket policy restrictions
- **Resolution**: Review task role policies and KMS key policies

#### CloudWatch Logs Not Appearing
- **Symptom**: No logs in CloudWatch
- **Possible Causes**:
  - Execution role missing CloudWatch permissions
  - KMS key policy doesn't allow CloudWatch
  - Log group doesn't exist
- **Resolution**: Verify execution role has `AmazonECSTaskExecutionRolePolicy` and KMS permissions

### Debugging Steps

1. **Check CloudWatch Logs**: Review `/aws/ecs/{runner_id}` log group
2. **Review IAM Roles**: Verify role policies and trust relationships
3. **Check CloudTrail**: Look for AssumeRole and API call failures
4. **Verify Network**: Ensure subnets have internet access
5. **Test KMS Keys**: Verify KMS key policies allow necessary services

### Getting Help

- Check [SECURITY.md](SECURITY.md) for security-related questions
- Review [ARCHITECTURE.md](ARCHITECTURE.md) for architectural understanding
- Review AWS ECS documentation for Fargate-specific issues
- Check Humanitec Platform Orchestrator documentation

## Compliance and Governance

### Supported Compliance Frameworks

This module implements controls that support:
- SOC 2
- ISO 27001
- HIPAA (with proper KMS configuration)
- PCI DSS
- GDPR

### Audit Logging

All API calls are logged via AWS CloudTrail (must be enabled in your account):
- IAM role assumptions
- ECS task launches
- S3 access
- KMS key usage

### Resource Tagging

Apply comprehensive tags for governance:

```hcl
additional_tags = {
  Environment        = "production"
  CostCenter         = "platform-engineering"
  DataClassification = "internal"
  ComplianceScope    = "sox,pci"
  Owner              = "platform-team@example.com"
  Project            = "platform-orchestrator"
  BackupPolicy       = "daily"
  MaintenanceWindow  = "sun:03:00-sun:04:00"
}
```

## Testing

### Running Terraform Tests

The module includes Terraform native tests:

```bash
terraform init
terraform test
```

### Validation

Validate your configuration before applying:

```bash
terraform init
terraform validate
terraform plan
```

### Integration Testing

For integration testing in your environment:

1. Deploy to a test/staging environment first
2. Verify ECS tasks can be launched
3. Verify S3 bucket access
4. Verify CloudWatch logs are being written
5. Test OIDC authentication from Humanitec

## Contributing

Contributions are welcome! Please ensure:
- Code follows Terraform best practices
- All tests pass
- Documentation is updated
- Security considerations are addressed

## Support and Maintenance

This module follows semantic versioning. For support:
- Open an issue for bugs or feature requests
- Review existing issues and discussions
- Check the changelog for recent updates

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
