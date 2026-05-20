output "bucket_id" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.s3_logs.id
}

output "bucket_arn" {
  description = "S3 bucket ARN"
  value       = aws_s3_bucket.s3_logs.arn
}