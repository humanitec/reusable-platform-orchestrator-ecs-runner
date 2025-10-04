provider "aws" {
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_requesting_account_id  = true
  skip_metadata_api_check     = true
  access_key                  = "mock_access_key"
  secret_key                  = "mock_secret_key"
}

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
}

run "test_with_custom_prefix" {
  command = plan

  variables {
    region           = "eu-west-1"
    runner_id_prefix = "test-prefix"
  }

  # Note: runner_id and ecs_cluster_name contain random values only known at apply time
  # so we can't assert on them in plan mode
}

run "test_with_defaults" {
  command = plan

  variables {
    region = "ap-southeast-1"
  }

  # Note: runner_id and ecs_cluster_name contain random values only known at apply time
  # so we can't assert on them in plan mode
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

  # Note: runner_id contains random values only known at apply time when not explicitly provided
}

run "test_with_additional_tags" {
  command = plan

  variables {
    region = "us-east-1"
    additional_tags = {
      Environment = "test"
      Team        = "platform"
    }
  }

  # Note: runner_id and ecs_cluster_name contain random values only known at apply time
  # This test just validates that the plan succeeds with additional tags
}
