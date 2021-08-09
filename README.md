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

### To destroy the cluster and clean-up all base infrastructure resources

```
./destroy-eks-dev.sh
```

