# Role for PR workflow - read only
resource "aws_iam_role" "github_actions_plan" {
  name = "github-actions-plan-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::173036476311:oidc-provider/token.actions.githubusercontent.com"
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

resource "aws_iam_role" "github_actions_apply" {
  name = "github-actions-apply-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::173036476311:oidc-provider/token.actions.githubusercontent.com"
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

resource "aws_iam_role_policy_attachment" "plan_readonly" {
  role       = aws_iam_role.github_actions_plan.name
  policy_arn = "arn:aws:iam::aws:policy/ReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "apply_admin" {
  role       = aws_iam_role.github_actions_apply.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"
}

output "github_actions_plan_role_arn" {
  value       = aws_iam_role.github_actions_plan.arn
  description = "Add to GitHub Secrets as AWS_ROLE_ARN"
}

output "github_actions_apply_role_arn" {
  value       = aws_iam_role.github_actions_apply.arn
  description = "Add to GitHub Secrets as AWS_ROLE_ARN_APPLY"
}