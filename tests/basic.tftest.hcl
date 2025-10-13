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
    region                    = "us-west-2"
    subnet_ids                = ["subnet-xyz789"]
    existing_ecs_cluster_name = "existing-cluster"
    humanitec_org_id          = "test-org-abc"
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

run "test_with_existing_oidc_provider" {
  command = plan

  variables {
    region                     = "us-east-1"
    subnet_ids                 = ["subnet-test789"]
    humanitec_org_id           = "test-org-jkl"
    existing_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/oidc.humanitec.dev"
  }

  # This test validates that the plan succeeds when using an existing OIDC provider
}

run "test_with_custom_oidc_hostname" {
  command = plan

  variables {
    region           = "eu-central-1"
    subnet_ids       = ["subnet-test012"]
    humanitec_org_id = "test-org-mno"
    oidc_hostname    = "custom-oidc.example.com"
  }

  # This test validates that the plan succeeds with a custom OIDC hostname
}

run "test_with_existing_oidc_and_custom_hostname" {
  command = plan

  variables {
    region                     = "ap-northeast-1"
    subnet_ids                 = ["subnet-test345"]
    humanitec_org_id           = "test-org-pqr"
    existing_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/custom-oidc.example.com"
    oidc_hostname              = "custom-oidc.example.com"
  }

  # This test validates that the plan succeeds when using an existing OIDC provider with custom hostname
}

run "test_region_is_used_in_resources" {
  command = plan

  variables {
    region                    = "us-west-2"
    subnet_ids                = ["subnet-region-test"]
    humanitec_org_id          = "test-org-region"
    existing_ecs_cluster_name = "existing-cluster-region-test"
  }

  assert {
    condition     = can(regex("arn:aws:ecs:us-west-2:.*:cluster/existing-cluster-region-test", output.ecs_cluster_arn))
    error_message = "ECS cluster ARN should include the region us-west-2"
  }
}
