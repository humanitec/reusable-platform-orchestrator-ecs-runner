# Main Terraform configuration for ECS Runner with Humanitec Platform Orchestrator
# This is a skeleton module that will be expanded with actual resources

# Generate a runner ID if one is not provided
resource "random_id" "runner_id" {
  count       = var.runner_id == null ? 1 : 0
  byte_length = 8
  prefix      = "${var.runner_id_prefix}-"
}

# Generate a random suffix for the cluster name to avoid conflicts
resource "random_id" "cluster_suffix" {
  count       = local.create_ecs_cluster ? 1 : 0
  byte_length = 4
}

locals {
  runner_id           = var.runner_id != null ? var.runner_id : random_id.runner_id[0].hex
  create_ecs_cluster  = var.ecs_cluster_name == null
  ecs_cluster_name    = var.ecs_cluster_name != null ? var.ecs_cluster_name : aws_ecs_cluster.main[0].name
}

# Create a new ECS cluster if one is not provided
resource "aws_ecs_cluster" "main" {
  count = local.create_ecs_cluster ? 1 : 0
  name  = "${local.runner_id}-cluster-${random_id.cluster_suffix[0].hex}"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(
    {
      ManagedBy = "terraform"
    },
    var.additional_tags
  )
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
