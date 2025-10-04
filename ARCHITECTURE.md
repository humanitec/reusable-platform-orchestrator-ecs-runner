# Architecture Overview

This document provides a detailed overview of the architecture and components of the ECS Runner module.

## High-Level Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                        Humanitec Platform                        │
│                    (External Service)                            │
└──────────────────────────┬──────────────────────────────────────┘
                           │ OIDC Authentication
                           │ (No long-lived credentials)
                           ▼
┌─────────────────────────────────────────────────────────────────┐
│                         AWS Account                              │
│                                                                  │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │            IAM OIDC Identity Provider                       │ │
│  │  (https://oidc.humanitec.dev)                              │ │
│  └────────────────┬───────────────────────────────────────────┘ │
│                   │                                              │
│                   ▼                                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │      IAM Role: ECS Task Manager                            │ │
│  │  - Authenticated via OIDC                                  │ │
│  │  - Can manage ECS tasks                                    │ │
│  │  - Can register task definitions                           │ │
│  │  - Can pass execution/task roles                           │ │
│  └────────────────┬───────────────────────────────────────────┘ │
│                   │                                              │
│                   ▼                                              │
│  ┌────────────────────────────────────────────────────────────┐ │
│  │               ECS Cluster                                   │ │
│  │  - Fargate capacity provider                               │ │
│  │  - Container Insights enabled                              │ │
│  │                                                             │ │
│  │  ┌──────────────────────────────────────────────────────┐ │ │
│  │  │              ECS Tasks                                │ │ │
│  │  │                                                        │ │ │
│  │  │  Execution Role:                                      │ │ │
│  │  │  - Pull container images from ECR                    │ │ │
│  │  │  - Write logs to CloudWatch                          │ │ │
│  │  │                                                        │ │ │
│  │  │  Task Role:                                           │ │ │
│  │  │  - Access S3 bucket for artifacts                    │ │ │
│  │  │  - Additional permissions as needed                  │ │ │
│  │  └──────────────┬───────────────────────────────────────┘ │ │
│  └─────────────────┼───────────────────────────────────────────┘ │
│                    │                                              │
│                    ├────────────────┐                             │
│                    │                │                             │
│                    ▼                ▼                             │
│  ┌───────────────────────┐  ┌──────────────────────────┐        │
│  │   CloudWatch Logs     │  │    S3 Bucket             │        │
│  │  - Task logs          │  │  - Runner artifacts      │        │
│  │  - Exec logs          │  │  - Encrypted (KMS)       │        │
│  │  - Encrypted (KMS)    │  │  - Versioning enabled    │        │
│  │  - Retention policy   │  │  - Lifecycle policies    │        │
│  └───────────────────────┘  └──────────────────────────┘        │
│                                                                  │
└─────────────────────────────────────────────────────────────────┘
```

## Components

### 1. OIDC Identity Provider

**Purpose**: Enables secure authentication from Humanitec Platform Orchestrator to AWS without long-lived credentials.

**Configuration**:
- URL: `https://oidc.humanitec.dev`
- Thumbprint: `9e99a48a9960b14926bb7f3b02e22da2b0ab7280`
- Client ID: `sts.amazonaws.com`

**Security Features**:
- No static credentials stored
- JWT-based authentication
- Time-limited session tokens
- Organization and runner-scoped access

### 2. IAM Roles

#### ECS Task Manager Role
**Purpose**: Allows Humanitec to manage ECS tasks and task definitions.

**Trust Policy**: Only accepts tokens from Humanitec OIDC provider with:
- Correct audience (`sts.amazonaws.com`)
- Matching organization ID and runner ID

**Permissions**:
- `ecs:RunTask` - Launch new ECS tasks
- `ecs:DescribeTasks` - Get task status
- `ecs:ListTasks` - List running tasks
- `ecs:RegisterTaskDefinition` - Create task definitions
- `ecs:DeregisterTaskDefinition` - Remove task definitions
- `ecs:DeleteTaskDefinition` - Delete task definitions
- `ecs:TagResource`, `ecs:UntagResource`, `ecs:ListTagsForResource` - Manage tags
- `iam:PassRole` - Pass execution and task roles to ECS (restricted to ECS tasks service)

#### ECS Task Execution Role
**Purpose**: Used by ECS to set up the task (pull images, write logs).

**Trust Policy**: Trusted by ECS tasks service.

**Permissions**:
- `AmazonECSTaskExecutionRolePolicy` (AWS managed)
  - Pull images from ECR
  - Write to CloudWatch Logs
  - Access Secrets Manager (if needed)
- Additional KMS permissions for encrypted CloudWatch Logs

#### ECS Task Role
**Purpose**: Used by the application running in the task.

**Trust Policy**: 
- Trusted by ECS tasks service
- Trusted by ECS Task Manager role (for AssumeRole)

**Permissions**:
- S3 bucket access (GetObject, PutObject, ListBucket)
- Scoped to the specific runner artifacts bucket

### 3. ECS Cluster

**Configuration**:
- Capacity Providers: FARGATE and FARGATE_SPOT
- Default Strategy: FARGATE with base 1, weight 1
- Container Insights: Enabled

**Features**:
- Serverless compute (no EC2 management)
- Automatic scaling
- Built-in monitoring and metrics
- Cost optimization with Spot instances available

### 4. S3 Bucket

**Purpose**: Store runner artifacts, build outputs, and temporary files.

**Security Features**:
- Public access blocked at all levels
- Server-side encryption (AES256 or KMS)
- Versioning enabled for compliance
- Lifecycle policies for cost optimization

**Lifecycle Configuration**:
- Non-current versions transition to STANDARD_IA after 30 days
- Non-current versions expire after 90 days
- Incomplete multipart uploads aborted after 7 days

**Access Control**:
- Only accessible by task role
- No public access
- IAM-based access control

### 5. CloudWatch Logs

**Purpose**: Centralized logging for ECS tasks and exec sessions.

**Log Groups**:
- `/aws/ecs/{runner_id}` - Task logs
- `/aws/ecs/{runner_id}/exec` - ECS Exec session logs

**Configuration**:
- Configurable retention (1-3653 days)
- Optional KMS encryption
- Integrated with Container Insights

## Data Flow

### 1. Authentication Flow
```
Humanitec Platform
    │
    ├─ 1. Request temporary credentials
    │      (with JWT token)
    ▼
AWS STS (via OIDC)
    │
    ├─ 2. Validate JWT token
    │      - Check audience
    │      - Check subject (org+runner)
    │      - Verify signature
    ▼
    │
    ├─ 3. Return temporary credentials
    │      (Access Key, Secret, Session Token)
    ▼
ECS Task Manager Role
```

### 2. Task Execution Flow
```
Humanitec Platform (authenticated)
    │
    ├─ 1. Register task definition
    │      (if not exists)
    ▼
ECS API
    │
    ├─ 2. RunTask with:
    │      - Task definition
    │      - Execution role
    │      - Task role
    │      - Subnet IDs
    │      - Security groups
    ▼
ECS Control Plane
    │
    ├─ 3. Schedule task on Fargate
    ▼
Fargate
    │
    ├─ 4. Assume execution role
    │
    ├─ 5. Pull container image
    │      (using execution role)
    │
    ├─ 6. Start container with task role
    ▼
Running Task
    │
    ├─ 7. Write logs to CloudWatch
    │      (using execution role)
    │
    ├─ 8. Access S3 artifacts
    │      (using task role)
    ▼
Task Completion
```

## Networking Considerations

### Subnet Requirements
- ECS tasks must be launched in subnets with outbound internet access
- Private subnets with NAT Gateway recommended
- Public subnets with public IP assignment possible (not recommended)

### Required Outbound Access
- AWS ECS API endpoints
- AWS ECR API and Docker registry
- AWS S3 endpoints
- AWS CloudWatch Logs endpoints
- AWS STS endpoints
- Humanitec Platform (if applicable)

### VPC Endpoints (Recommended)
For enhanced security and reduced data transfer costs:
- `com.amazonaws.{region}.ecs`
- `com.amazonaws.{region}.ecs-agent`
- `com.amazonaws.{region}.ecs-telemetry`
- `com.amazonaws.{region}.ecr.api`
- `com.amazonaws.{region}.ecr.dkr`
- `com.amazonaws.{region}.s3` (Gateway endpoint)
- `com.amazonaws.{region}.logs`
- `com.amazonaws.{region}.sts`

## Scaling Considerations

### Task Scaling
- Tasks are created on-demand by Humanitec
- No pre-provisioned capacity required
- Fargate automatically provisions compute resources
- Limited by AWS service quotas for Fargate tasks

### Cost Optimization
- Use FARGATE_SPOT for non-critical workloads
- Configure lifecycle policies to reduce S3 storage costs
- Set appropriate CloudWatch log retention
- Use VPC endpoints to reduce data transfer costs

## High Availability

### Multi-AZ Deployment
Deploy across multiple availability zones:
```hcl
module "ecs_runner" {
  subnet_ids = [
    "subnet-az1-private",
    "subnet-az2-private",
    "subnet-az3-private"
  ]
}
```

### Failure Handling
- ECS automatically restarts failed tasks (if configured)
- Fargate handles underlying infrastructure failures
- S3 versioning protects against accidental deletions
- CloudWatch Logs ensure audit trail even during failures

## Monitoring and Observability

### Built-in Metrics (Container Insights)
- CPU utilization
- Memory utilization
- Network I/O
- Disk I/O
- Task count

### CloudWatch Logs
- Task stdout/stderr
- ECS Exec session logs
- Structured logging support

### Recommended Alarms
- Task failure rate
- S3 bucket size
- CloudWatch Logs volume
- IAM AssumeRole failures

## Security Layers

1. **Authentication Layer**: OIDC federation with JWT validation
2. **Authorization Layer**: IAM roles with least privilege
3. **Network Layer**: VPC, subnets, security groups
4. **Encryption Layer**: KMS for data at rest, TLS for data in transit
5. **Audit Layer**: CloudTrail, CloudWatch Logs

## Extension Points

The module is designed to be extended for specific use cases:

1. **Custom IAM Policies**: Add additional policies to task role
2. **Security Groups**: Provide custom security groups for network control
3. **KMS Keys**: Use organization-specific KMS keys
4. **Tags**: Apply comprehensive tagging for governance
5. **Existing Clusters**: Integrate with existing ECS clusters

## Best Practices

1. **Use private subnets** for ECS tasks
2. **Enable KMS encryption** for compliance
3. **Configure VPC endpoints** to reduce costs and improve security
4. **Set appropriate log retention** based on compliance requirements
5. **Use permissions boundaries** in large organizations
6. **Tag all resources** for cost allocation and governance
7. **Monitor with CloudWatch** alarms and dashboards
8. **Review IAM policies** regularly
9. **Enable S3 versioning** for data protection
10. **Use multiple availability zones** for high availability
