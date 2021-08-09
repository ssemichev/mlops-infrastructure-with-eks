# AWS infrastructure

### Prerequisites
* AWS CLI (>=2.2.26)
* kubectl (>=1.21)
* eksctl (>=0.59.0)
* aws-iam-authenticator (>=0.5.3)
* istioctl (>=1.10.3)

### To create K8S cluster

```
cd ..
./bootstrap-eks-dev.sh
```

### To change number of workers in the nodegroup
```
eksctl scale nodegroup --cluster=mlops-dev --nodes=3 cpu-workers-nodegroup
```

### To destroy the cluster and clean-up all base infrastructure resources

```
./destroy-eks-dev.sh
```

### To connect to EKS cluster

1) Use original kubeconfig created by build script
```
aws s3 cp s3://esimplicity-mlops/eks/configs/dev/config-mlops-dev ~/.kube/config-mlops-dev
export KUBECONFIG=~/.kube/config-mlops-dev
kubectl get nodes
eksctl get nodegroups --cluster mlops-dev
```

or
2) Generate the new kubeconfig via `eks update-kubeconfig` command

```
aws eks --region us-east-2 list-clusters
aws eks --region us-east-2 update-kubeconfig --name mlops-dev
kubectl get nodes
eksctl get nodegroups --cluster mlops-dev
```

