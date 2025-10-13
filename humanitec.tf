resource "platform-orchestrator_serverless_ecs_runner" "runner" {
  id          = local.runner_id
  description = "Deploys using the ${local.ecs_cluster_name} ECS cluster in ${var.region}"

  runner_configuration = {
    auth = {
      role_arn = aws_iam_role.ecs_task_manager.arn
    }
    job = {
      region             = var.region
      cluster            = local.ecs_cluster_name
      execution_role_arn = aws_iam_role.execution.arn
      subnets            = var.subnets

      task_role_arn        = aws_iam_role.task.arn
      is_public_ip_enabled = false
      security_groups      = var.security_group_ids

      environment = var.environment
      secrets     = var.secrets
    }
  }

  state_storage_configuration = {
    type = "s3"
    s3_configuration = {
      bucket = aws_s3_bucket.state.name
    }
  }
}
