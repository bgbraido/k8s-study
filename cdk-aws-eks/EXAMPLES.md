# AWS EKS CDK Deployment - Examples

This directory contains example configurations for common use cases.

## Example 1: Development Cluster

Deploy a small, cost-effective development cluster:

```bash
./deploy.sh dev-cluster us-east-1 dev
```

Or with custom parameters:

```bash
cdk deploy \
  -c clusterName=dev-cluster \
  -c environment=dev \
  -c minNodeCount=1 \
  -c maxNodeCount=3 \
  -c desiredNodeCount=2 \
  -c nodeInstanceType=t3.small
```

## Example 2: Production Cluster

Deploy a production-grade cluster with multiple nodes:

```bash
./deploy.sh prod-cluster us-east-1 prod
```

Or:

```bash
cdk deploy \
  -c clusterName=prod-cluster \
  -c environment=prod \
  -c minNodeCount=3 \
  -c maxNodeCount=10 \
  -c desiredNodeCount=5 \
  -c nodeInstanceType=t3.large
```

## Example 3: Custom VPC Configuration

Deploy with custom network settings:

```bash
cdk deploy \
  -c clusterName=custom-cluster \
  -c vpcCidr=172.16.0.0/16 \
  -c privateSubnetCidr1=172.16.1.0/24 \
  -c privateSubnetCidr2=172.16.2.0/24 \
  -c publicSubnetCidr1=172.16.101.0/24 \
  -c publicSubnetCidr2=172.16.102.0/24
```

## Example 4: High-Performance Cluster

Deploy with powerful compute nodes for demanding workloads:

```bash
cdk deploy \
  -c clusterName=performance-cluster \
  -c nodeInstanceType=c5.2xlarge \
  -c minNodeCount=2 \
  -c maxNodeCount=20 \
  -c desiredNodeCount=5
```

## Example 5: Memory-Optimized Cluster

Deploy for memory-intensive workloads (databases, cache):

```bash
cdk deploy \
  -c clusterName=memory-cluster \
  -c nodeInstanceType=r5.xlarge \
  -c minNodeCount=2 \
  -c maxNodeCount=10 \
  -c desiredNodeCount=3
```

## Post-Deployment Tasks

### 1. Configure kubectl

```bash
aws eks update-kubeconfig --name dev-cluster --region us-east-1
```

### 2. Verify Cluster

```bash
kubectl cluster-info
kubectl get nodes
```

### 3. Deploy a Sample Application

```bash
kubectl create namespace demo
kubectl create deployment nginx --image=nginx:latest -n demo
kubectl expose deployment nginx --port=80 --type=LoadBalancer -n demo

# Get LoadBalancer URL
kubectl get svc -n demo
```

### 4. Install Metrics Server (for HPA)

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

### 5. Install AWS Load Balancer Controller

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=dev-cluster
```

## Cleanup Examples

### Delete specific cluster

```bash
cdk destroy -c clusterName=dev-cluster
```

### Delete all stacks

```bash
./cleanup.sh dev-cluster
```

## Monitoring

### View Control Plane Logs

```bash
aws logs describe-log-groups --query 'logGroups[].logGroupName' | grep eks
aws logs tail /aws/eks/dev-cluster/cluster --follow
```

### Monitor Nodes

```bash
kubectl describe nodes
kubectl top nodes
```

### Monitor Pods

```bash
kubectl top pods --all-namespaces
```
