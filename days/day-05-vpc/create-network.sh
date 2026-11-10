#!/usr/bin/env bash
set -euo pipefail
: "${AWS_REGION:=eu-west-2}"
: "${VPC_CIDR:=10.20.0.0/16}"
aws sts get-caller-identity --query '{Account:Account,Arn:Arn}' --output table
printf 'Proposed VPC: %s in %s\n' "$VPC_CIDR" "$AWS_REGION"
[[ "${1:-}" == --create ]] || { echo 'Dry run. Explicit --create required.'; exit 0; }
read -r -p 'Type CREATE to create the tagged VPC: ' confirm
[[ "$confirm" == CREATE ]] || exit 1
aws ec2 create-vpc --region "$AWS_REGION" --cidr-block "$VPC_CIDR" --tag-specifications 'ResourceType=vpc,Tags=[{Key=Name,Value=shop-dev-vpc},{Key=Project,Value=aws-cloud-engineering-in-10-days}]' --query 'Vpc.{VpcId:VpcId,CidrBlock:CidrBlock}' --output table
