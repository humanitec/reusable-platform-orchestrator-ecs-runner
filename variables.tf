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

variable "existing_oidc_provider_arn" {
  description = "The ARN of an existing OIDC provider to use. If not provided, a new OIDC provider will be created"
  type        = string
  default     = null
}

variable "oidc_hostname" {
  description = "The hostname of the OIDC provider. Defaults to oidc.humanitec.dev"
  type        = string
  default     = "oidc.humanitec.dev"
}
