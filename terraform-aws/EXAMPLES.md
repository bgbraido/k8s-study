# AWS EKS Terraform - Examples

This document shows common deployment scenarios.

## Example 1: Development Cluster

```bash
# Create terraform.tfvars with dev settings
cat > terraform.tfvars << EOF
aws_region         = "us-east-1"
environment        = "dev"
cluster_name       = "dev-cluster"
kubernetes_version = "1.28"

# Small cluster for dev
node_instance_type = "t3.small"
desired_node_count = 2
min_node_count     = 1
max_node_count     = 3
EOF

terraform init
terraform apply
```

## Example 2: Production Cluster

```bash
# Production with high availability
cat > terraform.tfvars << EOF
aws_region         = "us-east-1"
environment        = "prod"
cluster_name       = "prod-cluster"
kubernetes_version = "1.28"

# Larger cluster for prod
node_instance_type = "t3.large"
desired_node_count = 5
min_node_count     = 3
max_node_count     = 15

# Restrict public access to production cluster
public_access_cidrs = ["203.0.113.0/32"]  # Your corporate IP

# Enable spot instances for cost savings
enable_spot_instances   = true
spot_desired_node_count = 3
spot_max_node_count     = 10
EOF

terraform apply
```

## Example 3: Multi-Region Setup

Deploy the same cluster in multiple regions:

```bash
# us-east-1 cluster
terraform workspace new us-east-1
terraform init -backend-config="key=eks/us-east-1/terraform.tfstate"
terraform apply -var-file="configs/us-east-1.tfvars"

# us-west-2 cluster
terraform workspace new us-west-2
terraform init -backend-config="key=eks/us-west-2/terraform.tfstate"
terraform apply -var-file="configs/us-west-2.tfvars"
```

## Example 4: Cost-Optimized Setup

```bash
cat > terraform.tfvars << EOF
aws_region              = "us-east-1"
environment             = "dev"
cluster_name            = "cost-optimized-cluster"

# Smaller baseline
node_instance_type      = "t3.small"
desired_node_count      = 1
min_node_count          = 1
max_node_count          = 5

# Heavy use of spot instances
enable_spot_instances   = true
spot_instance_types     = ["t3.small", "t3.medium", "t2.small"]
spot_desired_node_count = 3
spot_max_node_count     = 10
EOF

terraform apply
```

## Example 5: High-Performance Cluster

```bash
cat > terraform.tfvars << EOF
aws_region         = "us-east-1"
environment        = "prod"
cluster_name       = "performance-cluster"

# High-performance compute nodes
node_instance_type = "c5.2xlarge"
desired_node_count = 5
min_node_count     = 3
max_node_count     = 20

# Larger disks for workloads
node_disk_size     = 100

# No spot instances for stability
enable_spot_instances = false
EOF

terraform apply
```

## Example 6: GPU Cluster

```bash
cat > terraform.tfvars << EOF
aws_region         = "us-east-1"
environment        = "dev"
cluster_name       = "gpu-cluster"

# GPU instance type
node_instance_type = "g4dn.xlarge"  # 1x NVIDIA T4 GPU
desired_node_count = 2
min_node_count     = 1
max_node_count     = 5

node_disk_size     = 100
EOF

terraform apply

# Deploy NVIDIA drivers
kubectl apply -f https://nvidia.github.io/k8s-device-plugin/nvidia-device-plugin.yml
```

## Post-Deployment

### 1. Get Cluster Access

```bash
aws eks update-kubeconfig --name dev-cluster --region us-east-1
```

### 2. Deploy Sample App

```bash
# Create namespace
kubectl create namespace demo

# Deploy nginx
kubectl create deployment nginx --image=nginx:latest -n demo
kubectl expose deployment nginx --port=80 --type=LoadBalancer -n demo

# Get service endpoint
kubectl get svc -n demo
```

### 3. Install Tools

```bash
# Metrics server (for HPA)
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

# AWS Load Balancer Controller
helm repo add eks https://aws.github.io/eks-charts
helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system
```

## Scaling Examples

### Scale Node Group

```bash
# Update desired count in terraform.tfvars
sed -i 's/desired_node_count = .*/desired_node_count = 10/' terraform.tfvars

terraform apply
```

### Auto-scaling with Cluster Autoscaler

```bash
helm repo add autoscaler https://kubernetes.github.io/autoscaler
helm install cluster-autoscaler autoscaler/cluster-autoscaler \
  -n kube-system \
  --set autoDiscovery.clusterName=dev-cluster
```

## Monitoring

### CloudWatch Logs

```bash
# View control plane logs
aws logs tail /aws/eks/dev-cluster/cluster --follow

# Export logs to S3
aws logs create-export-task \
  --log-group-name /aws/eks/dev-cluster/cluster \
  --from $(date -d '1 day ago' +%s)000 \
  --to $(date +%s)000 \
  --destination my-bucket
```

### kubectl Metrics

```bash
# Node metrics
kubectl top nodes

# Pod metrics
kubectl top pods --all-namespaces
```

## Cleanup

```bash
# Delete specific cluster
terraform destroy -var-file="configs/dev.tfvars"

# Delete all
terraform destroy
```
