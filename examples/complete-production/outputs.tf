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

output "cloudwatch_log_group_name" {
  description = "The name of the CloudWatch log group"
  value       = module.ecs_runner.cloudwatch_log_group_name
}

output "kms_key_arn" {
  description = "The ARN of the KMS key used for encryption"
  value       = aws_kms_key.runner.arn
}

output "security_group_id" {
  description = "The ID of the security group for ECS tasks"
  value       = aws_security_group.ecs_tasks.id
}

output "sns_topic_arn" {
  description = "The ARN of the SNS topic for alarms"
  value       = aws_sns_topic.ecs_runner_alarms.arn
}
