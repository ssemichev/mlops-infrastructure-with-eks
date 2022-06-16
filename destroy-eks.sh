#!/usr/bin/env bash
set -e

usage() {
  echo "Usage: $0 <cluster-name>"
  echo " e.g.: $0 eks-cluster-dev"
  exit 1
}

if [ -z "$1" ] && [ "" == "$cluster_name" ];then
  usage
fi

if [ "" == "$cluster_name" ];then
  export cluster_name=$1
  shift 1
fi

export AWS_DEFAULT_REGION=us-east-2

eksctl delete cluster --name=${cluster_name}

#aws ec2 describe-volumes --region us-east-2 \
#  --filters Name=tag:kubernetes.io/cluster/${cluster_name},Values=owned \
#  --query "Volumes[*].{ID:VolumeId}" --output text \
#| xargs -I{} aws ec2 delete-volume --volume-id {}
