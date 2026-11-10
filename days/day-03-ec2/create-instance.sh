#!/usr/bin/env bash
set -euo pipefail
: "${AWS_REGION:=eu-west-2}"
required=(AMI_ID SUBNET_ID SECURITY_GROUP_ID INSTANCE_PROFILE_NAME)
for key in "${required[@]}"; do [[ -n "${!key:-}" ]] || { echo "Set $key first" >&2; exit 2; }; done
aws sts get-caller-identity --query '{Account:Account,Arn:Arn}' --output table
printf 'Region: %s\nAMI: %s\nSubnet: %s\nSecurity group: %s\nProfile: %s\n' "$AWS_REGION" "$AMI_ID" "$SUBNET_ID" "$SECURITY_GROUP_ID" "$INSTANCE_PROFILE_NAME"
[[ "${1:-}" == --create ]] || { echo 'Inspection only. Run with --create after verifying values.'; exit 0; }
read -r -p 'Type CREATE to launch one billable EC2 instance: ' confirm
[[ "$confirm" == CREATE ]] || exit 1
aws ec2 run-instances --region "$AWS_REGION" --image-id "$AMI_ID" --instance-type "${INSTANCE_TYPE:-t3.micro}" --subnet-id "$SUBNET_ID" --security-group-ids "$SECURITY_GROUP_ID" --iam-instance-profile "Name=$INSTANCE_PROFILE_NAME" --user-data "file://$(cd "$(dirname "$0")" && pwd)/user-data.sh" --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=shop-dev},{Key=Project,Value=aws-cloud-engineering-in-10-days}]' --query 'Instances[].{InstanceId:InstanceId,State:State.Name}' --output table
