# Create a new ECS cluster if one is not provided
resource "aws_ecs_cluster" "main" {
  count  = local.create_ecs_cluster ? 1 : 0
  region = var.region
  name   = "${local.runner_id}-cluster-${random_id.suffix.hex}"

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
  region       = var.region

  capacity_providers = ["FARGATE", "FARGATE_SPOT"]

  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
    weight            = 1
    base              = 1
  }
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
          "ecs:ListTaskDefinitions",
          "ecs:RegisterTaskDefinition",
          "ecs:DeregisterTaskDefinition",
          "ecs:DeleteTaskDefinitions",
        ]
        # Unfortunately there isn't really a way to reduce the scope further here
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecs:TagResource",
          "ecs:UntagResource",
          "ecs:ListTagsForResource"
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
