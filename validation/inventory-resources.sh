#!/usr/bin/env bash
set -euo pipefail
command -v aws >/dev/null || { echo 'AWS CLI required' >&2; exit 2; }
: "${AWS_REGION:=eu-west-2}"
echo "READ-ONLY inventory for Region ${AWS_REGION}; not an exhaustive account inventory"
aws sts get-caller-identity --query '{Account:Account,Arn:Arn}' --output table
section(){ printf '\n--- %s ---\n' "$1"; }
section 'EC2 instances'; aws ec2 describe-instances --region "$AWS_REGION" --query 'Reservations[].Instances[].{Id:InstanceId,State:State.Name,Name:Tags[?Key==`Name`]|[0].Value}' --output table
section 'VPCs'; aws ec2 describe-vpcs --region "$AWS_REGION" --query 'Vpcs[].{Id:VpcId,CIDR:CidrBlock}' --output table
section 'ALBs/NLBs'; aws elbv2 describe-load-balancers --region "$AWS_REGION" --query 'LoadBalancers[].{Name:LoadBalancerName,State:State.Code,DNS:DNSName}' --output table
section 'Auto Scaling groups'; aws autoscaling describe-auto-scaling-groups --region "$AWS_REGION" --query 'AutoScalingGroups[].{Name:AutoScalingGroupName,Desired:DesiredCapacity}' --output table
section 'CloudFormation stacks'; aws cloudformation list-stacks --region "$AWS_REGION" --stack-status-filter CREATE_COMPLETE UPDATE_COMPLETE UPDATE_ROLLBACK_COMPLETE ROLLBACK_COMPLETE DELETE_FAILED --query 'StackSummaries[].{Name:StackName,Status:StackStatus}' --output table
section 'CloudWatch log groups'; aws logs describe-log-groups --region "$AWS_REGION" --query 'logGroups[].{Name:logGroupName,Retention:retentionInDays}' --output table
printf '\nReview S3, IAM, EIPs, NAT, target groups, launch templates and cross-Region resources separately. No resources were changed.\n'
