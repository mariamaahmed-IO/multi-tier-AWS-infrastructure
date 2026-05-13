# OIDC provider - tells AWS to trust GitHub
resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# Plan role - read only, any PR can use this
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
          "token.actions.githubusercontent.com:sub" = "repo:mariamaahmed-IO/multi-tier-AWS-infrastructure:pull_request"
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

# Plan role permissions - currently ReadOnlyAccess (about to fix this)
resource "aws_iam_role_policy_attachment" "plan_readonly" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

# Apply role permissions - full admin
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