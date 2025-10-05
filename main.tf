# Main Terraform configuration for ECS Runner with Humanitec Platform Orchestrator
# This is a skeleton module that will be expanded with actual resources

# Generate a runner ID if one is not provided
resource "random_id" "runner_id" {
  count       = var.runner_id == null ? 1 : 0
  byte_length = 8
  prefix      = "${var.runner_id_prefix}-"
}

# Generate a random suffix to avoid naming conflicts
resource "random_id" "suffix" {
  byte_length = 4
}

locals {
  runner_id          = var.runner_id != null ? var.runner_id : random_id.runner_id[0].hex
  create_ecs_cluster = var.existing_ecs_cluster_name == null
  ecs_cluster_name   = var.existing_ecs_cluster_name != null ? var.existing_ecs_cluster_name : aws_ecs_cluster.main[0].name
  ecs_cluster_arn    = local.create_ecs_cluster ? aws_ecs_cluster.main[0].arn : "arn:aws:ecs:${var.region}:*:cluster/${var.existing_ecs_cluster_name}"
  common_tags = merge(
    {
      ManagedBy = "terraform"
    },
    var.additional_tags
  )
}

# Create a new ECS cluster if one is not provided
resource "aws_ecs_cluster" "main" {
  count = local.create_ecs_cluster ? 1 : 0
  name  = "${local.runner_id}-cluster-${random_id.suffix.hex}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = local.common_tags
}

# Enable Fargate capacity provider for the cluster
resource "aws_ecs_cluster_capacity_providers" "main" {
  count        = local.create_ecs_cluster ? 1 : 0
  cluster_name = aws_ecs_cluster.main[0].name

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
}

# OIDC provider for Humanitec federation
resource "aws_iam_openid_connect_provider" "oidc" {
  url = "https://oidc.humanitec.dev"
  client_id_list = [
    "sts.amazonaws.com",
  ]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]

  tags = local.common_tags
}

# IAM role for managing ECS tasks with OIDC federation
resource "aws_iam_role" "ecs_task_manager" {
  name = "${local.runner_id}-ecs-task-manager-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.oidc.arn
        }
        Condition = {
          StringEquals = {
            "oidc.humanitec.dev:aud" = "sts.amazonaws.com"
            "oidc.humanitec.dev:sub" = "${var.humanitec_org_id}+${local.runner_id}"
          }
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM policy for ECS task management
resource "aws_iam_role_policy" "ecs_task_manager" {
  name = "${local.runner_id}-ecs-task-manager-policy"
  role = aws_iam_role.ecs_task_manager.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecs:RunTask",
          "ecs:DescribeTasks",
          "ecs:ListTasks"
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "ecs:cluster" = local.ecs_cluster_arn
          }
        }
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:DeleteTaskDefinition",
          "ecs:ListTaskDefinitions"
        ]
        Resource = local.ecs_cluster_arn
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:TagResource",
          "ecs:UntagResource",
          "ecs:ListTagsForResource"
        ]
        Resource = local.ecs_cluster_arn
      },
      {
        Effect = "Allow"
        Action = [
          "iam:PassRole"
        ]
        Resource = "*"
        Condition = {
          StringLike = {
            "iam:PassedToService" = "ecs-tasks.amazonaws.com"
          }
        }
      }
    ]
  })
}

# S3 bucket for runner artifacts
resource "aws_s3_bucket" "runner" {
  bucket = "${local.runner_id}-artifacts"

  tags = local.common_tags
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "runner" {
  bucket = aws_s3_bucket.runner.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM role for ECS task execution
resource "aws_iam_role" "execution" {
  name = "${local.runner_id}-execution-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })

  tags = local.common_tags
}

# Attach AWS managed policy for ECS task execution
resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# IAM role for ECS tasks
resource "aws_iam_role" "task" {
  name = "${local.runner_id}-task-${random_id.suffix.hex}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = aws_iam_role.ecs_task_manager.arn
        }
      }
    ]
  })

  tags = local.common_tags
}

# IAM policy for ECS task to access S3 bucket
resource "aws_iam_role_policy" "task_s3" {
  name = "${local.runner_id}-task-s3-policy"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.runner.arn,
          "${aws_s3_bucket.runner.arn}/*"
        ]
      }
    ]
  })
}
