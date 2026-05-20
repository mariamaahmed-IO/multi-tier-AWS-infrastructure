locals {
  name = "${var.project}-${var.env}"
}

#Key Pair
resource "tls_private_key" "utc" {
  algorithm = "RSA"
  rsa_bits  = 4096
}
resource "aws_key_pair" "utc_key_pair" {
  key_name   = "${local.name}-key-pair"
  public_key = tls_private_key.utc.public_key_openssh
  tags = {
    Name = "${local.name}-key-pair"
  }
}

#saving the private key to a local file .pem 
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.utc.private_key_pem
  filename        = "${path.module}/../../${local.name}-private_key.pem"
  file_permission = 0400

}

#Bastion Host 
resource "aws_instance" "bastion" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.public_subnet_id[0]
  vpc_security_group_ids      = [var.bastion_sg_id]
  key_name                    = aws_key_pair.utc_key_pair.key_name
  associate_public_ip_address = true
  tags = {
    Name = "${local.name}-bastion"
  }
}

#App server
resource "aws_instance" "app_server" {
  count                  = 2
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.private_subnet_id[count.index]
  vpc_security_group_ids = [var.app_sg_id]
  key_name               = aws_key_pair.utc_key_pair.key_name
  iam_instance_profile   = var.instance_profile_name

  user_data = base64encode(<<-EOF
  #!/bin/bash
  yum update -y
  yum install -y httpd.x86_64 amazon-efs-utils
  systemctl start httpd.service
  systemctl enable httpd.service
  echo "Hello World from $(hostname -f)" > /var/www/html/index.html

  mkdir -p /mnt/efs
  mount -t efs -o tls ${var.efs_dns_name}:/ /mnt/efs
  echo "${var.efs_dns_name}:/ /mnt/efs efs defaults,_netdev 0 0" >> /etc/fstab
EOF
  )
  associate_public_ip_address = false
  tags = {
    Name = "${local.name}-app-server-${count.index + 1}"
  }

}

