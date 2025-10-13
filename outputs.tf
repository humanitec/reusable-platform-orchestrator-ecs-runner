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
  value       = platform-orchestrator_serverless_ecs_runner.runner.id
}

output "s3_bucket" {
  description = "The name of the S3 bucket"
  value       = aws_s3_bucket.state.id
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster (either existing or newly created)"
  value       = local.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = local.create_ecs_cluster ? aws_ecs_cluster.main[0].arn : ""
}
