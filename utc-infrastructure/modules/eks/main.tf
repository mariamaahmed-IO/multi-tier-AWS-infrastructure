resource "aws_eks_cluster" "utc_main" {
  name     = var.cluster_name
  version = var.cluster_version
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access = true
    security_group_ids = [aws_security_group.eks_cluster_sg.id]
  }
   tags = {
     Name = var.cluster_name
     Environment = var.env
     }
     depends_on = [ aws_iam_role_policy_attachment.eks_cluster_policy ]
 }

 resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
   
 }

 resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
   
 }

 resource "aws_iam_role" "eks_node" {
  name = "${var.cluster_name}-eks-node-group-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
   
 }
 resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
   
 }

 resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
   
 }
 resource "aws_iam_role_policy_attachment" "eks_ecr_policy" {
  role       = aws_iam_role.eks_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
   
 }

 resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.utc_main.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.eks_node.name
  subnet_ids      = var.private_subnet_ids

  instance_types = [var.node_group_instance_type]
  scaling_config {
    desired_size = var.node_group_desired_size
    max_size     = var.node_group_desired_size + 1
    min_size     = var.node_group_min_size
  }
    update_config {
  
  max_unavailable = 1
}
   labels = {
     node-group = "private-workers"
     environment = var.env
    } 
   tags = {
     Name = "${var.cluster_name}-node-group"
     Environment = var.env
     }
   depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node_policy,
    aws_iam_role_policy_attachment.eks_cni_policy,
    aws_iam_role_policy_attachment.eks_ecr_policy,
  ]
}

resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.cluster_name}-sg"
  description = "Security group for EKS cluster"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow HTTPS to cluster API"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.cluster_name}-sg"
    Environment = var.env
  }
}
