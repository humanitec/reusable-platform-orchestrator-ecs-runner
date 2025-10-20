# S3 bucket for runner state files
resource "aws_s3_bucket" "state" {
  bucket = "${local.runner_id}-state"
  region = var.region

  tags = local.common_tags

  force_destroy = var.force_delete_s3
}

# Block public access to the S3 bucket
resource "aws_s3_bucket_public_access_block" "runner" {
  bucket = aws_s3_bucket.state.id
  region = var.region

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# IAM policy for ECS task to access S3 bucket
resource "aws_iam_role_policy" "task_s3" {
  name = "${local.runner_id}-task-s3-policy"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.state.arn,
          "${aws_s3_bucket.state.arn}/*"
        ]
      }
    ]
  })
}
