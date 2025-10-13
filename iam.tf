# OIDC provider for Humanitec federation
resource "aws_iam_openid_connect_provider" "oidc" {
  count = local.create_oidc_provider ? 1 : 0
  url   = "https://${local.oidc_hostname}"
  client_id_list = [
    "sts.amazonaws.com",
  ]

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
          Federated = local.oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${local.oidc_hostname}:aud" = "sts.amazonaws.com"
            "${local.oidc_hostname}:sub" = "${var.humanitec_org_id}+${local.runner_id}"
          }
        }
      }
    ]
  })

  tags = local.common_tags
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
