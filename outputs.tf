output "humanitec_role_arn" {
  description = "The ARN of the IAM role for Humanitec"
  value       = ""
}

output "execution_role_arn" {
  description = "The ARN of the ECS task execution role"
  value       = ""
}

output "task_role_arn" {
  description = "The ARN of the ECS task role"
  value       = ""
}

output "runner_id" {
  description = "The ID of the runner"
  value       = local.runner_id
}

output "s3_bucket" {
  description = "The name of the S3 bucket"
  value       = ""
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster (either existing or newly created)"
  value       = local.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "The ARN of the ECS cluster"
  value       = local.create_ecs_cluster ? aws_ecs_cluster.main[0].arn : ""
}
