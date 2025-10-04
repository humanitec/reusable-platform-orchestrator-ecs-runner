variable "region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name (e.g., production, staging)"
  type        = string
  default     = "production"
}

variable "vpc_id" {
  description = "VPC ID where ECS tasks will run"
  type        = string
}

variable "subnet_ids" {
  description = "List of private subnet IDs for ECS tasks"
  type        = list(string)
}

variable "humanitec_org_id" {
  description = "Humanitec organization ID"
  type        = string
}

variable "runner_id" {
  description = "Runner ID (if not provided, will be generated)"
  type        = string
  default     = null
}

variable "cloudwatch_log_retention_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 90
}

variable "iam_role_permissions_boundary" {
  description = "ARN of IAM permissions boundary policy"
  type        = string
  default     = null
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "platform-engineering"
}

variable "compliance_scope" {
  description = "Compliance frameworks (comma-separated)"
  type        = string
  default     = "sox,iso27001"
}

variable "owner_email" {
  description = "Owner email address"
  type        = string
}

variable "alarm_email" {
  description = "Email address for alarm notifications"
  type        = string
  default     = ""
}

variable "s3_bucket_size_alarm_threshold" {
  description = "S3 bucket size alarm threshold in bytes"
  type        = number
  default     = 107374182400 # 100 GB
}
