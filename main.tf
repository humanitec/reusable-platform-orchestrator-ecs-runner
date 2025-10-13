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
  runner_id            = var.runner_id != null ? var.runner_id : random_id.runner_id[0].hex
  create_ecs_cluster   = var.existing_ecs_cluster_name == null
  ecs_cluster_name     = var.existing_ecs_cluster_name != null ? var.existing_ecs_cluster_name : aws_ecs_cluster.main[0].name
  ecs_cluster_arn      = local.create_ecs_cluster ? aws_ecs_cluster.main[0].arn : "arn:aws:ecs:${var.region}:*:cluster/${var.existing_ecs_cluster_name}"
  create_oidc_provider = var.existing_oidc_provider_arn == null
  oidc_provider_arn    = var.existing_oidc_provider_arn != null ? var.existing_oidc_provider_arn : aws_iam_openid_connect_provider.oidc[0].arn
  oidc_hostname        = var.oidc_hostname
  common_tags = merge(
    {
      ManagedBy = "terraform"
    },
    var.additional_tags
  )
}
