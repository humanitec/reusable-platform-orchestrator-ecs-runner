# Security Best Practices

This document outlines security best practices for deploying and managing the ECS Runner module in production environments.

## Encryption at Rest

### S3 Bucket Encryption
The module supports encryption for the S3 bucket used for runner artifacts:

- **Default**: Uses AWS managed encryption (SSE-S3)
- **Recommended for Enterprise**: Use AWS KMS Customer Managed Keys (CMK) for enhanced control and audit capabilities

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  # ... other variables ...
  
  enable_s3_encryption = true
  kms_key_arn         = aws_kms_key.runner.arn
}
```

### CloudWatch Logs Encryption
CloudWatch logs can be encrypted using the same KMS key:

```hcl
kms_key_arn = aws_kms_key.runner.arn
```

Ensure your KMS key policy allows CloudWatch Logs service to use the key:

```json
{
  "Sid": "Allow CloudWatch Logs",
  "Effect": "Allow",
  "Principal": {
    "Service": "logs.amazonaws.com"
  },
  "Action": [
    "kms:Encrypt",
    "kms:Decrypt",
    "kms:ReEncrypt*",
    "kms:GenerateDataKey*",
    "kms:CreateGrant",
    "kms:DescribeKey"
  ],
  "Resource": "*",
  "Condition": {
    "ArnLike": {
      "kms:EncryptionContext:aws:logs:arn": "arn:aws:logs:REGION:ACCOUNT_ID:log-group:/aws/ecs/*"
    }
  }
}
```

## IAM Security

### Permissions Boundary
For large organizations with strict IAM policies, use permissions boundaries:

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  # ... other variables ...
  
  iam_role_permissions_boundary = "arn:aws:iam::123456789012:policy/EnterprisePermissionsBoundary"
}
```

### IAM Role Path
Organize IAM roles using paths for better management:

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  # ... other variables ...
  
  iam_role_path = "/platform/runners/"
}
```

### Principle of Least Privilege
The module follows the principle of least privilege:
- Task execution role: Only has permissions to pull container images and write logs
- Task role: Only has permissions to access the specific S3 bucket
- ECS task manager role: Only has permissions to manage ECS tasks within the specific cluster

### OIDC Federation
The module uses OIDC federation for secure authentication with Humanitec:
- No long-lived credentials required
- Identity verification through JWT tokens
- Scoped to specific organization and runner ID

## Network Security

### VPC Configuration
Always deploy the runner in private subnets:

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  # ... other variables ...
  
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.ecs_tasks.id]
}
```

### Security Groups
Implement restrictive security group rules:
- Only allow outbound HTTPS (443) to AWS services
- Use VPC endpoints for AWS services when possible
- Deny all inbound traffic unless specifically required

Example security group:

```hcl
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "ecs-runner-"
  vpc_id      = module.vpc.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS to AWS services"
  }

  tags = {
    Name = "ecs-runner-sg"
  }
}
```

## Data Protection

### S3 Bucket Versioning
Enable versioning for compliance and data recovery:

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  # ... other variables ...
  
  s3_bucket_versioning_enabled = true
}
```

### S3 Bucket Protection
For production environments, disable force destroy:

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  # ... other variables ...
  
  s3_bucket_force_destroy = false  # Prevent accidental deletion
}
```

### Lifecycle Policies
The module automatically configures lifecycle policies to:
- Transition old versions to STANDARD_IA after 30 days
- Delete old versions after 90 days
- Abort incomplete multipart uploads after 7 days

## Logging and Monitoring

### CloudWatch Log Retention
Configure appropriate log retention for compliance:

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  # ... other variables ...
  
  cloudwatch_log_retention_days = 90  # Adjust based on compliance requirements
}
```

### Container Insights
The module automatically enables Container Insights for the ECS cluster, providing:
- Task-level metrics
- Container-level metrics
- Performance monitoring

## Compliance Considerations

### OIDC Thumbprint Verification
The module uses a hardcoded OIDC thumbprint for Humanitec. Verify this thumbprint matches your requirements:

```
9e99a48a9960b14926bb7f3b02e22da2b0ab7280
```

If you need to rotate or verify the thumbprint, use:

```bash
echo | openssl s_client -servername oidc.humanitec.dev -connect oidc.humanitec.dev:443 2>/dev/null | openssl x509 -fingerprint -noout | cut -d'=' -f2 | tr -d ':' | tr '[:upper:]' '[:lower:]'
```

### Tagging Strategy
Use comprehensive tagging for cost allocation and compliance:

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  # ... other variables ...
  
  additional_tags = {
    Environment         = "production"
    CostCenter          = "platform-engineering"
    DataClassification  = "internal"
    ComplianceScope     = "sox"
    Owner               = "platform-team@example.com"
    Project             = "platform-orchestrator"
  }
}
```

## Security Checklist

Before deploying to production, ensure:

- [ ] KMS encryption is enabled for S3 and CloudWatch Logs
- [ ] S3 bucket versioning is enabled
- [ ] S3 force_destroy is set to false
- [ ] IAM permissions boundary is configured (if required)
- [ ] Private subnets are used for ECS tasks
- [ ] Security groups follow least privilege
- [ ] CloudWatch log retention meets compliance requirements
- [ ] All resources are properly tagged
- [ ] OIDC thumbprint has been verified
- [ ] VPC endpoints are configured for AWS services
- [ ] Container Insights is enabled for monitoring
- [ ] IAM roles are organized with appropriate paths

## Incident Response

### Rotating Credentials
If you suspect credential compromise:

1. Review CloudWatch Logs for unauthorized access
2. Review S3 bucket access logs (if enabled)
3. Update the runner ID to force re-authentication
4. Rotate KMS keys if necessary
5. Review IAM role trust policies

### Auditing Access
Use AWS CloudTrail to audit:
- AssumeRoleWithWebIdentity calls
- ECS task executions
- S3 bucket access
- KMS key usage

## Additional Resources

- [AWS Security Best Practices](https://aws.amazon.com/security/best-practices/)
- [ECS Security Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/security.html)
- [Humanitec Platform Orchestrator Documentation](https://docs.humanitec.com/)
