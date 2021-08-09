#!/usr/bin/env bash
set -e

export AWS_DEFAULT_REGION=us-east-2
export AWS_ACCESS_KEY_ID=$AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY=$AWS_SECRET_ACCESS_KEY

export ENVIRONMENT=dev
export EKS_CLUSTER_NAME=mlops-${ENVIRONMENT}
export AWS_REGION=${AWS_DEFAULT_REGION}
export K8S_VERSION=1.19
export KUBE_CONFIG=~/.kube/config-${EKS_CLUSTER_NAME}
export SSH_PUBLIC_KEY_PATH=~/.ssh/mlops-eks.pub

export OWNER=eSimplicity
export PROJECT=mlops

echo "ENVIRONMENT: $ENVIRONMENT"
echo "EKS_CLUSTER_NAME: $EKS_CLUSTER_NAME"
echo "KUBE_CONFIG: $KUBE_CONFIG"

export EC2_CPU_INSTANCE_TYPE=m5.large
export EC2_CPU_DESIRED_CAPACITY=2
export EC2_GPU_INSTANCE_TYPE=p2.xlarge
export EC2_GPU_DESIRED_CAPACITY=0

echo "EC2_CPU_INSTANCE_TYPE: $EC2_CPU_INSTANCE_TYPE"
echo "EC2_CPU_DESIRED_CAPACITY: $EC2_CPU_DESIRED_CAPACITY"
echo "EC2_GPU_INSTANCE_TYPE: $EC2_GPU_INSTANCE_TYPE"
echo "EC2_GPU_DESIRED_CAPACITY: $EC2_GPU_DESIRED_CAPACITY"

envsubst < ./k8s/cluster.template.yaml > ./k8s/cluster.yaml

echo "Running dry-run..."

eksctl create cluster -f ./k8s/cluster.yaml --dry-run

while true; do
    read -p "Do you wish to build the new EKS cluster (yes/no)?" yn
    case $yn in
        [Yy]* ) eksctl create cluster -f ./k8s/cluster.yaml --kubeconfig ${KUBE_CONFIG} || rm ./k8s/cluster.yaml; break;;
        [Nn]* ) rm ./k8s/cluster.yaml; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

rm ./k8s/cluster.yaml

aws s3 cp ${KUBE_CONFIG} s3://esimplicity-mlops/eks/configs/${ENVIRONMENT}/config-${EKS_CLUSTER_NAME}

echo ""
echo "Completed successfully"
