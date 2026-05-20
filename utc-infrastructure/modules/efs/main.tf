locals {
  name = "${var.project}-${var.env}"
}

resource "aws_security_group" "efs_sg" {
  name        = "${local.name}-efs-sg"
  description = "Security group for EFS"
  vpc_id      = var.vpc_id

  ingress {
    description     = "Allow NFS from app servers"
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${local.name}-efs-sg"
  }
}

resource "aws_efs_file_system" "efs" {
  creation_token   = "${local.name}-efs"
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  encrypted        = true
  tags = {
    Name    = "${local.name}-efs"
    Project = var.project
  }
}

resource "aws_efs_mount_target" "efs_mount" {
  file_system_id  = aws_efs_file_system.efs.id
  count           = length(var.azs)
  subnet_id       = var.private_subnet_ids[count.index]
  security_groups = [aws_security_group.efs_sg.id]
}