# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- S3 bucket encryption with optional KMS key support
- S3 bucket versioning for compliance requirements
- S3 bucket lifecycle policies for cost optimization
- CloudWatch log groups for ECS tasks with configurable retention
- CloudWatch log groups for ECS Exec sessions
- CloudWatch log encryption with optional KMS key
- IAM role path support for better organization
- IAM role permissions boundary support for enterprise environments
- S3 bucket force_destroy control variable
- Comprehensive security documentation (SECURITY.md)
- Detailed architecture documentation (ARCHITECTURE.md)
- Contributing guidelines (CONTRIBUTING.md)
- Complete production example with KMS, alarms, and monitoring
- Basic example for simple deployments
- CloudWatch log group outputs
- Cost estimation guidance in README
- Troubleshooting section in README
- Compliance and governance documentation
- Variable validation for CloudWatch log retention
- Variable validation for IAM role path

### Changed
- Enhanced README with production-ready examples
- Improved variable descriptions
- Updated outputs to include CloudWatch log groups
- Container Insights enabled by default on new ECS clusters

### Security
- S3 encryption enabled by default (AES256)
- S3 bucket versioning enabled by default
- S3 force_destroy disabled by default for production safety
- CloudWatch logs retention policy (30 days default)
- IAM policies follow least privilege principle
- Support for KMS customer-managed keys

## [1.0.0] - Initial Release

### Added
- ECS cluster creation with Fargate support
- OIDC federation for Humanitec authentication
- IAM roles for ECS task management
- IAM roles for ECS task execution
- IAM roles for ECS tasks
- S3 bucket for runner artifacts
- S3 bucket public access blocking
- Container Insights support
- Automatic runner ID generation
- Support for existing ECS clusters
- Security group support
- Comprehensive tagging support
- Basic Terraform tests

### Features
- Secure OIDC-based authentication
- Least privilege IAM policies
- Multi-subnet support
- Cost optimization with Fargate Spot
- Flexible configuration options

[Unreleased]: https://github.com/astromechza/reusable-platform-orchestrator-ecs-runner/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/astromechza/reusable-platform-orchestrator-ecs-runner/releases/tag/v1.0.0
