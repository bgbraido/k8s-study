# GKE Cluster Deployment with Terraform

This directory contains Terraform configuration to deploy a production-ready Google Kubernetes Engine (GKE) cluster on Google Cloud Platform.

## Prerequisites

1. **Google Cloud SDK**: Install the [Cloud SDK](https://cloud.google.com/sdk/docs/install)
2. **Terraform**: Install [Terraform](https://www.terraform.io/downloads) >= 1.0
3. **kubectl**: Install [kubectl](https://kubernetes.io/docs/tasks/tools/) for cluster management
4. **GCP Project**: Create a GCP project and set up billing

## Setup Instructions

### 1. Authenticate with GCP

```bash
gcloud auth login
gcloud config set project YOUR-PROJECT-ID
gcloud auth application-default login
```

### 2. Enable Required APIs

```bash
gcloud services enable container.googleapis.com
gcloud services enable compute.googleapis.com
gcloud services enable servicenetworking.googleapis.com
```

### 3. Configure Terraform Variables

Copy the example variables file and update with your values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your specific configuration:

- `project_id`: Your GCP project ID
- `region`: GCP region (e.g., us-central1, europe-west1)
- `cluster_name`: Name for your cluster
- `environment`: dev, staging, or prod

### 4. Initialize Terraform

```bash
terraform init
```

### 5. Plan the Deployment

```bash
terraform plan -out=tfplan
```

Review the resources that will be created.

### 6. Apply the Configuration

```bash
terraform apply tfplan
```

This will create:

- VPC Network with custom subnets
- GKE Cluster with autoscaling
- Node Pool with configurable machine types
- Firewall rules for network access
- Cloud Logging and Monitoring integration

## Configuration Options

### Machine Types

- `e2-standard-2`: 2 vCPU, 8 GB memory (dev environments)
- `e2-standard-4`: 4 vCPU, 16 GB memory (default, general purpose)
- `n2-standard-4`: 4 vCPU, 16 GB memory (higher performance)
- `n2-standard-8`: 8 vCPU, 32 GB memory (production workloads)

### Cost Optimization

- Set `preemptible = true` for dev/test environments to reduce costs (can be interrupted)
- Adjust `max_node_count` based on your workload requirements
- Consider using `e2` machine types for cost-effective general workloads

## Post-Deployment

### Get Cluster Credentials

```bash
gcloud container clusters get-credentials $(terraform output -raw kubernetes_cluster_name) \
  --region $(terraform output -raw region) \
  --project $(terraform output -raw project_id)
```

### Verify Cluster

```bash
kubectl cluster-info
kubectl get nodes
```

### Deploy Sample Application

```bash
kubectl create deployment nginx --image=nginx:latest
kubectl expose deployment nginx --port=80 --type=LoadBalancer
```

## Outputs

The Terraform configuration provides several outputs:

- `cluster_name`: The name of the GKE cluster
- `cluster_host`: The endpoint of the Kubernetes control plane
- `vpc_name`: The VPC network name
- `subnet_name`: The subnet name

View outputs after apply:

```bash
terraform output
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete the cluster and all associated resources.

## Network Details

- **Subnet CIDR**: 10.0.0.0/20 (default)
- **Pod CIDR**: 10.4.0.0/14 (default, supports ~260k pods)
- **Service CIDR**: 10.0.16.0/20 (default)

These ranges are configurable via `terraform.tfvars`.

## Security Features

- **Workload Identity**: Enabled for secure pod-to-GCP service authentication
- **Network Policy**: Enabled for fine-grained network access control
- **Shielded Nodes**: Secure boot and integrity monitoring enabled
- **VPC-native**: Uses custom networking instead of route-based
- **Private Google Access**: Enables private connectivity to Google APIs

## Troubleshooting

### Common Issues

**Issue**: "Error: Quota exceeded"

- Check your GCP quota limits: `gcloud compute project-info describe --project=$(gcloud config get-value project)`
- Request quota increase if needed

**Issue**: "Error: API not enabled"

- Run the "Enable Required APIs" section above

**Issue**: "kubectl: Unable to connect to cluster"

- Verify credentials: `gcloud container clusters get-credentials`
- Check cluster status: `gcloud container clusters describe CLUSTER_NAME --region REGION`

## Additional Resources

- [GKE Documentation](https://cloud.google.com/kubernetes-engine/docs)
- [Terraform GCP Provider](https://registry.terraform.io/providers/hashicorp/google/latest/docs)
- [GKE Best Practices](https://cloud.google.com/kubernetes-engine/docs/best-practices)
