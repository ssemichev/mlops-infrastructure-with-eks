# AWS infrastructure

### Prerequisites
* AWS CLI (>=2.2.26)
* kubectl (>=1.21)
* eksctl (>=0.59.0)
* aws-iam-authenticator (>=0.5.3)
* istioctl (>=1.10.3)

### To create K8S cluster

```
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
aws s3 cp s3://ex-mlops-eks/eks/configs/dev/config-mlops-dev ~/.kube/config-mlops-dev
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

### Open Kubernetes Web UI (Dashboard)

1) Start the kubectl proxy in the terminal window (should be configured to connect to K8S cluster)
```
>kubectl proxy
```
2) Open this URL in your browser
```
>open http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/#!/login
```
3) Choose Token, paste the <authentication_token> from $DASHBOARD_TOKEN output

### Troubleshooting

```
kubectl describe pod <pod-name> -n <ns-name>
```