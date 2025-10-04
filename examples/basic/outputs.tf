output "runner_id" {
  description = "The ID of the runner"
  value       = module.ecs_runner.runner_id
}

output "humanitec_role_arn" {
  description = "The ARN of the IAM role for Humanitec"
  value       = module.ecs_runner.humanitec_role_arn
}

output "s3_bucket" {
  description = "The name of the S3 bucket"
  value       = module.ecs_runner.s3_bucket
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = module.ecs_runner.ecs_cluster_name
}
