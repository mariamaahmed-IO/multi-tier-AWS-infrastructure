locals {
  name = "${var.project}-${var.env}"
}

# ─── SNS TOPIC ──────────────────────────────────────────────────────
resource "aws_sns_topic" "sns_asg" {
  name = "${local.name}-auto-scaling"

  tags = {
    Name = "${local.name}-auto-scaling"
  }
}

# ─── EMAIL SUBSCRIPTION ─────────────────────────────────────────────
resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.sns_asg.arn
  protocol  = "email"
  endpoint  = var.email
}