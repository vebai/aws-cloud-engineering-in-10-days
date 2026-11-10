#!/usr/bin/env bash
set -euo pipefail
: "${LAB_USER_NAME:=cloud-engineering-lab-reader}"
if [[ "${1:-}" != "--create" ]]; then echo "Dry run. To create IAM user '${LAB_USER_NAME}', explicitly run: $0 --create"; exit 0; fi
command -v aws >/dev/null
aws sts get-caller-identity --query '{Account:Account,Arn:Arn}' --output table
read -r -p "Type CREATE to confirm IAM user creation (no policies or keys attached): " agree
[[ "$agree" == CREATE ]] || { echo 'Cancelled'; exit 1; }
aws iam create-user --user-name "$LAB_USER_NAME" --query 'User.{UserName:UserName,Arn:Arn}' --output table
