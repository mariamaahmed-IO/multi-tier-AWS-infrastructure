locals {
  name = "${var.project}-${var.env}"
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name        = "${local.name}-db-subnet-group"
  subnet_ids  = var.private_subnet_ids
  description = "Subnet group for RDS instance"

  tags = {
    Name = "${local.name}-db-subnet-group"
  }

}

resource "aws_db_instance" "db_instance" {
  identifier = "${local.name}-db"
  #Engine
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = var.db_instance_class

  # Strorage
  allocated_storage     = 20
  storage_type          = "gp2"
  max_allocated_storage = 100
  storage_encrypted     = true

  #Credentials
  db_name  = var.db_name
  username = var.db_username
  password = var.db_password

  #Networking
  db_subnet_group_name   = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [var.db_sg_id]
  publicly_accessible    = false

  #Availability
  multi_az = var.multi_az

  #Backup
  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  #Snapshot on destroy
  skip_final_snapshot = var.skip_final_snapshot
  deletion_protection = false

  tags = {
    Name = "${local.name}-db"
  }

}