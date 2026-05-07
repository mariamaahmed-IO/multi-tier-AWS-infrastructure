locals {
  name = "${var.project}-${var.env}"
}
resource "aws_iam_role" "ec2_role" {
  name = "${local.name}-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
  tags = {
    Name = "${local.name}-ec2-role"
  }
  
}

resource "aws_iam_policy" "ec2_s3_policy" {
  name        = "${local.name}-ec2-s3-policy"
  description = "Policy to allow EC2 instances to read/write S3 buckets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket",
          "s3:PutObject",
          "s3:DeleteObject"  
        ]
        Effect   = "Allow"
        Resource = [
            var.s3_bucket_arn,
            "${var.s3_bucket_arn}/*"
        ]
      }
    ]
  })
  tags = {
    Name = "${local.name}-ec2-s3-policy"
  }
  
}
resource "aws_iam_role_policy_attachment" "ec2_role_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "${local.name}-ec2-profile"
  role = aws_iam_role.ec2_role.name

  tags = {
    Name="${local.name}-ec2-profile"
  }
  
}