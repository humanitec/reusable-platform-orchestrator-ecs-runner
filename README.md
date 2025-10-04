# Reusable Platform Orchestrator ECS Runner

A reusable Terraform module for setting up an ECS Runner for the Humanitec Platform Orchestrator.

## Overview

This module provides a reusable configuration for deploying an ECS-based runner that integrates with the Humanitec Platform Orchestrator. The module handles runner ID generation, AWS resource provisioning, and IAM role configuration.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.0 |
| aws | >= 4.0 |
| random | >= 3.0 |
| platform-orchestrator | ~> 2.0 |

## Usage

### Basic Example

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region = "us-east-1"
}
```

### With Custom Runner ID

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region    = "us-east-1"
  runner_id = "my-custom-runner"
}
```

### With Custom Runner ID Prefix

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region           = "us-east-1"
  runner_id_prefix = "prod-runner"
}
```

### With Existing ECS Cluster

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region           = "us-east-1"
  ecs_cluster_name = "existing-cluster"
}
```

### With Additional Tags

```hcl
module "ecs_runner" {
  source = "github.com/astromechza/reusable-platform-orchestrator-ecs-runner"
  
  region = "us-east-1"
  
  additional_tags = {
    Environment = "production"
    Team        = "platform"
    CostCenter  = "engineering"
  }
}
```

## Variables

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| region | The AWS region where resources will be created | `string` | n/a | yes |
| runner_id | The ID of the runner. If not provided, one will be generated using runner_id_prefix | `string` | `null` | no |
| runner_id_prefix | The prefix to use when generating a runner ID. Only used if runner_id is not provided | `string` | `"runner"` | no |
| ecs_cluster_name | The name of an existing ECS cluster to use. If not provided, a new Fargate-compatible cluster will be created | `string` | `null` | no |
| additional_tags | Additional tags to apply to resources created by this module | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| humanitec_role_arn | The ARN of the IAM role for Humanitec |
| execution_role_arn | The ARN of the ECS task execution role |
| task_role_arn | The ARN of the ECS task role |
| runner_id | The ID of the runner |
| s3_bucket | The name of the S3 bucket |
| ecs_cluster_name | The name of the ECS cluster (either existing or newly created) |
| ecs_cluster_arn | The ARN of the ECS cluster |

## License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.
