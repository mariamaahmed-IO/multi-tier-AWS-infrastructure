# OIDC provider - tells AWS to trust GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Plan role - for PRs, any branch
resource "aws_iam_role" "github_actions_plan" {
  name = "github-actions-plan-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:mariamaahmed-IO/multi-tier-AWS-infrastructure:*"
        }
      }
    }]
  })
}

# Apply role - full access, main branch only
resource "aws_iam_role" "github_actions_apply" {
  name = "github-actions-apply-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          "token.actions.githubusercontent.com:sub" = "repo:mariamaahmed-IO/multi-tier-AWS-infrastructure:ref:refs/heads/main"
        }
      }
    }]
  })
}

# Custom policy for plan role
# Fixes the DynamoDB AccessDenied error
resource "aws_iam_policy" "plan_permissions" {
  name = "github-actions-plan-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:us-east-1:173036476311:table/utc-terraform-locks"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::utc-terraform-state-dev",
          "arn:aws:s3:::utc-terraform-state-dev/*"
        ]
      },
      {
        Effect  = "Allow"
        Action  = ["*"]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:ResourceTag/ReadOnly" = "true"
          }
        }
      }
    ]
  })
}

# Attach ReadOnlyAccess for describing AWS resources
resource "aws_iam_role_policy_attachment" "plan_readonly" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Attach custom policy that adds DynamoDB + S3 write for state
resource "aws_iam_role_policy_attachment" "plan_custom" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = aws_iam_policy.plan_permissions.arn
}

# Apply role - full admin
resource "aws_iam_role_policy_attachment" "apply_admin" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

# Outputs
output "github_actions_plan_role_arn" {
  value       = aws_iam_role.github_actions_plan.arn
  description = "Add to GitHub Secrets as AWS_ROLE_ARN"
}

output "github_actions_apply_role_arn" {
  value       = aws_iam_role.github_actions_apply.arn
  description = "Add to GitHub Secrets as AWS_ROLE_ARN_APPLY"
}


resource "aws_iam_policy" "eks_pass_role" {
  name = "github-actions-eks-pass-role"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "eks.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "apply_pass_role" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = aws_iam_policy.eks_pass_role.arn
}