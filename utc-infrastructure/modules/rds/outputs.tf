output "db_endpoint" {
  description = "RDS instance endpoint"
  value       = aws_db_instance.db_instance.endpoint
}

output "db_name" {
  description = "Database name"
  value       = aws_db_instance.db_instance.db_name
}

output "db_port" {
  description = "Database port"
  value       = aws_db_instance.db_instance.port
  
  }