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
    region           = "us-east-1"
    subnet_ids       = ["subnet-12345678", "subnet-87654321"]
    runner_id        = "test-runner"
    humanitec_org_id = "test-org-123"
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
    subnet_ids       = ["subnet-12345678"]
    runner_id_prefix = "test-prefix"
    humanitec_org_id = "test-org-456"
  }

  # Note: runner_id and ecs_cluster_name contain random values only known at apply time
  # so we can't assert on them in plan mode
}

run "test_with_defaults" {
  command = plan

  variables {
    region           = "ap-southeast-1"
    subnet_ids       = ["subnet-abc123"]
    humanitec_org_id = "test-org-789"
  }

  # Note: runner_id and ecs_cluster_name contain random values only known at apply time
  # so we can't assert on them in plan mode
}

run "test_with_existing_cluster" {
  command = plan

  variables {
    region           = "us-west-2"
    subnet_ids       = ["subnet-xyz789"]
    ecs_cluster_name = "existing-cluster"
    humanitec_org_id = "test-org-abc"
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
    region           = "us-east-1"
    subnet_ids       = ["subnet-test123"]
    humanitec_org_id = "test-org-def"
    additional_tags = {
      Environment = "test"
      Team        = "platform"
    }
  }

  # Note: runner_id and ecs_cluster_name contain random values only known at apply time
  # This test just validates that the plan succeeds with additional tags
}

run "test_with_security_groups" {
  command = plan

  variables {
    region             = "us-east-1"
    subnet_ids         = ["subnet-test456"]
    security_group_ids = ["sg-12345678", "sg-87654321"]
    humanitec_org_id   = "test-org-ghi"
  }

  # This test validates that the plan succeeds with security groups specified
}
