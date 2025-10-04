run "test_with_explicit_runner_id" {
  command = plan

  variables {
    region    = "us-east-1"
    runner_id = "test-runner"
  }

  assert {
    condition     = output.runner_id == "test-runner"
    error_message = "Runner ID should match the provided value"
  }

  assert {
    condition     = output.ecs_cluster_name == "test-runner-cluster"
    error_message = "ECS cluster name should be based on runner ID"
  }
}

run "test_with_custom_prefix" {
  command = plan

  variables {
    region           = "eu-west-1"
    runner_id_prefix = "test-prefix"
  }

  assert {
    condition     = length(output.runner_id) > 0
    error_message = "Runner ID should be generated"
  }

  assert {
    condition     = can(regex("^test-prefix-", output.runner_id))
    error_message = "Runner ID should start with the custom prefix"
  }

  assert {
    condition     = length(output.ecs_cluster_name) > 0
    error_message = "ECS cluster name should be generated"
  }
}

run "test_with_defaults" {
  command = plan

  variables {
    region = "ap-southeast-1"
  }

  assert {
    condition     = length(output.runner_id) > 0
    error_message = "Runner ID should be generated with default prefix"
  }

  assert {
    condition     = can(regex("^runner-", output.runner_id))
    error_message = "Runner ID should start with default prefix 'runner-'"
  }

  assert {
    condition     = length(output.ecs_cluster_name) > 0
    error_message = "ECS cluster name should be generated"
  }
}

run "test_with_existing_cluster" {
  command = plan

  variables {
    region           = "us-west-2"
    ecs_cluster_name = "existing-cluster"
  }

  assert {
    condition     = output.ecs_cluster_name == "existing-cluster"
    error_message = "ECS cluster name should match the provided existing cluster"
  }

  assert {
    condition     = length(output.runner_id) > 0
    error_message = "Runner ID should still be generated"
  }
}
