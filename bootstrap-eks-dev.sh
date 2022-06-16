#!/usr/bin/env bash
set -e

source ./bash-utils.sh

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

export EC2_CPU_INSTANCE_TYPE=m5.xlarge
export EC2_CPU_DESIRED_CAPACITY=5
export EC2_GPU_INSTANCE_TYPE=p2.xlarge
export EC2_GPU_DESIRED_CAPACITY=0

echo "EC2_CPU_INSTANCE_TYPE: $EC2_CPU_INSTANCE_TYPE"
echo "EC2_CPU_DESIRED_CAPACITY: $EC2_CPU_DESIRED_CAPACITY"
echo "EC2_GPU_INSTANCE_TYPE: $EC2_GPU_INSTANCE_TYPE"
echo "EC2_GPU_DESIRED_CAPACITY: $EC2_GPU_DESIRED_CAPACITY"

envsubst < ./k8s-objects/cluster.template.yaml > ./k8s-objects/cluster.yaml

print "Running dry-run..."

eksctl create cluster -f ./k8s-objects/cluster.yaml --dry-run

while true; do
    read -p "Do you wish to build the new EKS cluster (yes/no)?" yn
    case $yn in
        [Yy]* ) eksctl create cluster -f ./k8s-objects/cluster.yaml --kubeconfig ${KUBE_CONFIG} || rm ./k8s/cluster.yaml; break;;
        [Nn]* ) rm ./k8s-objects/cluster.yaml; exit;;
        * ) echo "Please answer yes or no.";;
    esac
done

rm ./k8s-objects/cluster.yaml

aws s3 cp ${KUBE_CONFIG} s3://esimplicity-mlops/eks/configs/${ENVIRONMENT}/config-${EKS_CLUSTER_NAME}

kubectl create namespace mlops-dev || true
kubectl create namespace mlops-qa || true

print  "Existing namespaces:"
kubectl get namespaces

# https://docs.aws.amazon.com/eks/latest/userguide/dashboard-tutorial.html

print  "Deploying the Metrics Server:"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

print "Verifying that the metrics-server deployment is running the desired number of pods with the following command"
kubectl get deployment metrics-server -n kube-system

print "Deploying the Kubernetes Dashboard"
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.5/aio/deploy/recommended.yaml
kubectl wait --for=condition=available --timeout=600s -n kubernetes-dashboard deployment.apps/dashboard-metrics-scraper

print "Creating an eks-admin service account and cluster role binding"
kubectl apply -f ./kubectl-objects/eks-admin-service-account.yaml
sleep 10


DASHBOARD_ADMIN_SECRET_NAME=$(kubectl -n kube-system get secret | grep eks-admin | awk '{print $1}')
DASHBOARD_TOKEN=$(kubectl -n kube-system describe secret $DASHBOARD_ADMIN_SECRET_NAME)

echo "DASHBOARD_TOKEN: $DASHBOARD_TOKEN"
echo "See Open Kubernetes Web UI (Dashboard) section in the README.md file"



print "Completed successfully"



