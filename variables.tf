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

variable "ecs_cluster_name" {
  description = "The name of an existing ECS cluster to use. If not provided, a new Fargate-compatible cluster will be created"
  type        = string
  default     = null
}

variable "additional_tags" {
  description = "Additional tags to apply to resources created by this module"
  type        = map(string)
  default     = {}
}
