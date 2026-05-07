#!/usr/bin/env bash
set -euo pipefail

BUCKET_NAME="utc-terraform-state-dev"
TABLE_NAME="utc-terraform-locks"
REGION="us-east-1"

echo "Creating S3 state bucket..."

aws s3api create-bucket \
  --bucket "$BUCKET_NAME" \
  --region "$REGION"

echo "Enabling versioning..."

aws s3api put-bucket-versioning \
  --bucket "$BUCKET_NAME" \
  --versioning-configuration Status=Enabled

echo "Blocking public access..."

aws s3api put-public-access-block \
  --bucket "$BUCKET_NAME" \
  --public-access-block-configuration \
  "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"

echo "Enabling encryption..."

aws s3api put-bucket-encryption \
  --bucket "$BUCKET_NAME" \
  --server-side-encryption-configuration '{
    "Rules": [
      {
        "ApplyServerSideEncryptionByDefault": {
          "SSEAlgorithm": "AES256"
        }
      }
    ]
  }'

echo "Creating DynamoDB lock table..."

aws dynamodb create-table \
  --table-name "$TABLE_NAME" \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --billing-mode PAY_PER_REQUEST \
  --region "$REGION"

echo "Waiting for DynamoDB table to become active..."

aws dynamodb wait table-exists \
  --table-name "$TABLE_NAME" \
  --region "$REGION"

echo "Terraform backend bootstrap complete."