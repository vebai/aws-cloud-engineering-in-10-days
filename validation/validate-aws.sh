#!/usr/bin/env bash
set -euo pipefail
command -v aws >/dev/null || { echo 'AWS CLI is required' >&2; exit 2; }
: "${AWS_REGION:=eu-west-2}"
printf 'AWS CLI: '; aws --version
printf 'Requested Region: %s\n' "$AWS_REGION"
aws sts get-caller-identity --query '{Account:Account,Arn:Arn,UserId:UserId}' --output table
aws ec2 describe-regions --region "$AWS_REGION" --region-names "$AWS_REGION" --query 'Regions[].RegionName' --output table
printf 'PASS read-only account and Region preflight. Verify the returned identity before proceeding.\n'
