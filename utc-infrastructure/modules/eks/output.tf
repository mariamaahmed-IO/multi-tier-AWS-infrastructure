output "cluster_name" {
  description = "EKS cluster name"
  value       = aws_eks_cluster.utc_main.name
}

output "cluster_endpoint" {
  description = "EKS cluster API endpoint"
  value       = aws_eks_cluster.utc_main.endpoint
}

output "cluster_certificate_authority" {
  description = "Certificate for authenticating to the cluster"
  value       = aws_eks_cluster.utc_main.certificate_authority[0].data
  sensitive   = true
}

output "node_group_role_arn" {
  description = "IAM role ARN for worker nodes"
  value       = aws_iam_role.eks_node.arn
}

output "cluster_security_group_id" {
  description = "Security group ID for the cluster"
  value       = aws_security_group.eks_cluster_sg.id
}