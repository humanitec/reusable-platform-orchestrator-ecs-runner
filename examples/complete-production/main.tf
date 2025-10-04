# Complete production example with all enterprise features enabled
# This example demonstrates best practices for production deployments

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

  default_tags {
    tags = {
      Project     = "platform-orchestrator"
      ManagedBy   = "terraform"
      Environment = var.environment
    }
  }
}

data "aws_caller_identity" "current" {}

# KMS key for encryption
resource "aws_kms_key" "runner" {
  description             = "KMS key for ECS runner encryption"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = {
    Name        = "${var.environment}-ecs-runner-key"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "runner" {
  name          = "alias/${var.environment}-ecs-runner"
  target_key_id = aws_kms_key.runner.key_id
}

# KMS key policy to allow CloudWatch Logs and S3
data "aws_iam_policy_document" "kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "Allow CloudWatch Logs"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["logs.amazonaws.com"]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:CreateGrant",
      "kms:DescribeKey"
    ]
    resources = ["*"]
    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values   = ["arn:aws:logs:${var.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/ecs/*"]
    }
  }

  statement {
    sid    = "Allow S3"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["s3.amazonaws.com"]
    }
    actions = [
      "kms:Decrypt",
      "kms:GenerateDataKey"
    ]
    resources = ["*"]
  }
}

resource "aws_kms_key_policy" "runner" {
  key_id = aws_kms_key.runner.id
  policy = data.aws_iam_policy_document.kms_key_policy.json
}

# Security group for ECS tasks
resource "aws_security_group" "ecs_tasks" {
  name_prefix = "${var.environment}-ecs-runner-"
  description = "Security group for ECS runner tasks"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTPS to AWS services and internet"
  }

  egress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "HTTP for package downloads"
  }

  tags = {
    Name        = "${var.environment}-ecs-runner-sg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# ECS Runner module with all production features
module "ecs_runner" {
  source = "../.."

  region           = var.region
  subnet_ids       = var.subnet_ids
  humanitec_org_id = var.humanitec_org_id
  runner_id        = var.runner_id

  # Security configurations
  enable_s3_encryption         = true
  kms_key_arn                  = aws_kms_key.runner.arn
  s3_bucket_versioning_enabled = true
  s3_bucket_force_destroy      = false # Prevent accidental deletion in production

  # Logging configurations
  cloudwatch_log_retention_days = var.cloudwatch_log_retention_days

  # IAM configurations
  iam_role_path                 = "/platform/runners/"
  iam_role_permissions_boundary = var.iam_role_permissions_boundary

  # Network configurations
  security_group_ids = [aws_security_group.ecs_tasks.id]

  # Tagging for governance
  additional_tags = {
    Environment        = var.environment
    CostCenter         = var.cost_center
    DataClassification = "internal"
    ComplianceScope    = var.compliance_scope
    Owner              = var.owner_email
    BackupPolicy       = "enabled"
    MaintenanceWindow  = "sun:03:00-sun:04:00"
  }
}

# SNS topic for alarms
resource "aws_sns_topic" "ecs_runner_alarms" {
  name              = "${var.environment}-ecs-runner-alarms"
  kms_master_key_id = aws_kms_key.runner.id

  tags = {
    Name        = "${var.environment}-ecs-runner-alarms"
    Environment = var.environment
  }
}

resource "aws_sns_topic_subscription" "ecs_runner_alarms_email" {
  count     = var.alarm_email != "" ? 1 : 0
  topic_arn = aws_sns_topic.ecs_runner_alarms.arn
  protocol  = "email"
  endpoint  = var.alarm_email
}

# CloudWatch alarms for monitoring
resource "aws_cloudwatch_metric_alarm" "s3_bucket_size" {
  alarm_name          = "${var.environment}-ecs-runner-s3-bucket-size"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "BucketSizeBytes"
  namespace           = "AWS/S3"
  period              = "86400" # 24 hours
  statistic           = "Average"
  threshold           = var.s3_bucket_size_alarm_threshold
  alarm_description   = "This metric monitors S3 bucket size"
  alarm_actions       = [aws_sns_topic.ecs_runner_alarms.arn]

  dimensions = {
    BucketName  = module.ecs_runner.s3_bucket
    StorageType = "StandardStorage"
  }

  tags = {
    Name        = "${var.environment}-ecs-runner-s3-bucket-size"
    Environment = var.environment
  }
}
