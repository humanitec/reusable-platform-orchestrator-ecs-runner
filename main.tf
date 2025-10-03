# Main Terraform configuration for ECS Runner with Humanitec Platform Orchestrator
# This is a skeleton module that will be expanded with actual resources

# Generate a runner ID if one is not provided
resource "random_id" "runner_id" {
  count       = var.runner_id == null ? 1 : 0
  byte_length = 8
  prefix      = "${var.runner_id_prefix}-"
}

locals {
  runner_id = var.runner_id != null ? var.runner_id : random_id.runner_id[0].hex
}
