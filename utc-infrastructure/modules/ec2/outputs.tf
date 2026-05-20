output "bastion_public_ip" {
  description = "The public IP address of the bastion host"
  value       = aws_instance.bastion.public_ip

}

output "app_server_ids" {
  description = "The IDs of the application servers"
  value       = aws_instance.app_server[*].id
}

output "app_server_private_ips" {
  description = "The private IP addresses of the application servers"
  value       = aws_instance.app_server[*].private_ip

}

output "key_name" {
  description = "The name of the key pair used for SSH access"
  value       = aws_key_pair.utc_key_pair.key_name

}