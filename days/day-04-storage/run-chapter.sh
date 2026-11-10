#!/usr/bin/env bash
set -euo pipefail
: "${AWS_REGION:=eu-west-2}"
: "${BUCKET_NAME:?Set BUCKET_NAME to a bucket you own}"
aws sts get-caller-identity --query 'Arn' --output text
printf 'Inspecting bucket %s in %s\n' "$BUCKET_NAME" "$AWS_REGION"
aws s3api head-bucket --bucket "$BUCKET_NAME" --region "$AWS_REGION"
aws s3api get-public-access-block --bucket "$BUCKET_NAME" --region "$AWS_REGION" || echo 'Public Access Block not returned; investigate.'
aws s3api get-bucket-encryption --bucket "$BUCKET_NAME" --region "$AWS_REGION" || echo 'Bucket encryption status could not be verified.'
