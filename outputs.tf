output "humanitec_role_arn" {
  description = "The ARN of the IAM role for Humanitec"
  value       = aws_iam_role.ecs_task_manager.arn
}

output "execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = aws_iam_role.execution.arn
}

output "task_role_arn" {
  description = "The ARN of the ECS task role"
  value       = aws_iam_role.task.arn
}

output "runner_id" {
  description = "The ID of the runner"
  value       = local.runner_id
}

output "s3_bucket" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.runner.id
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster (either existing or newly created)"
  value       = local.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = local.ecs_cluster_arn
}

output "ecs_task_manager_role_arn" {
  description = "The ARN of the IAM role for managing ECS tasks"
  value       = aws_iam_role.ecs_task_manager.arn
}
