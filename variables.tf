variable "region" {
  description = "The AWS region where resources will be created"
  type        = string
}

variable "runner_id" {
  description = "The ID of the runner. If not provided, one will be generated using runner_id_prefix"
  type        = string
  default     = null
}

variable "runner_id_prefix" {
  description = "The prefix to use when generating a runner ID. Only used if runner_id is not provided"
  type        = string
  default     = "runner"
}

variable "existing_ecs_cluster_name" {
  description = "The name of an existing ECS cluster to use. If not provided, a new Fargate-compatible cluster will be created"
  type        = string
  default     = null
}

variable "additional_tags" {
  description = "Additional tags to apply to resources created by this module"
  type        = map(string)
  default     = {}
}

variable "subnet_ids" {
  description = "List of subnet IDs where ECS tasks will be launched. At least one subnet is required"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) > 0
    error_message = "At least one subnet ID must be provided"
  }
}

variable "security_group_ids" {
  description = "Optional list of security group IDs to attach to ECS tasks"
  type        = list(string)
  default     = []
}

variable "humanitec_org_id" {
  description = "The Humanitec organization ID for OIDC federation"
  type        = string
}

variable "enable_s3_encryption" {
  description = "Enable encryption for S3 bucket using AWS managed keys (SSE-S3)"
  type        = bool
  default     = true
}

variable "kms_key_arn" {
  description = "Optional KMS key ARN for encrypting S3 bucket and CloudWatch logs. If not provided, AWS managed keys will be used"
  type        = string
  default     = null
}

variable "s3_bucket_versioning_enabled" {
  description = "Enable versioning for the S3 bucket to support compliance requirements"
  type        = bool
  default     = true
}

variable "s3_bucket_force_destroy" {
  description = "Allow destruction of S3 bucket even if it contains objects. Set to false for production environments"
  type        = bool
  default     = false
}

variable "cloudwatch_log_retention_days" {
  description = "Number of days to retain CloudWatch logs. Must be one of: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653"
  type        = number
  default     = 30

  validation {
    condition     = contains([1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653], var.cloudwatch_log_retention_days)
    error_message = "CloudWatch log retention must be one of the valid values: 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653"
  }
}

variable "iam_role_path" {
  description = "Path for IAM roles. Useful for organizing roles in large AWS accounts"
  type        = string
  default     = "/"

  validation {
    condition     = can(regex("^/.*/$", var.iam_role_path)) || var.iam_role_path == "/"
    error_message = "IAM role path must start and end with '/'"
  }
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for IAM roles"
  type        = string
  default     = null
}
