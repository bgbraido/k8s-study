# AWS EKS Cluster Deployment with Terraform

This directory contains Terraform configuration to deploy a production-ready Amazon EKS (Elastic Kubernetes Service) cluster on AWS.

## Prerequisites

1. **AWS Account**: Create and configure an AWS account with appropriate permissions
2. **Terraform**: Install [Terraform](https://www.terraform.io/downloads) >= 1.0
3. **AWS CLI**: Install [AWS CLI v2](https://aws.amazon.com/cli/)
4. **kubectl**: Install [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Quick Start

### 1. Configure AWS Credentials

```bash
aws configure
# or set environment variables:
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=us-east-1
```

### 2. Prepare Configuration

```bash
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your desired configuration
```

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review and Deploy

```bash
# View planned infrastructure
terraform plan -out=tfplan

# Deploy the cluster
terraform apply tfplan

# Or deploy directly
terraform apply
```

## Configuration

### Main Variables

Edit `terraform.tfvars` to customize:

| Variable             | Default          | Description                      |
| -------------------- | ---------------- | -------------------------------- |
| `aws_region`         | `us-east-1`      | AWS region for deployment        |
| `cluster_name`       | `my-eks-cluster` | Name of the EKS cluster          |
| `kubernetes_version` | `1.28`           | Kubernetes version (1.27+)       |
| `environment`        | `dev`            | Environment (dev, staging, prod) |
| `vpc_cidr`           | `10.0.0.0/16`    | VPC CIDR block                   |
| `node_instance_type` | `t3.medium`      | EC2 instance type for nodes      |
| `desired_node_count` | `3`              | Desired number of nodes          |
| `min_node_count`     | `1`              | Minimum nodes for auto-scaling   |
| `max_node_count`     | `10`             | Maximum nodes for auto-scaling   |

### Network Configuration

```hcl
vpc_cidr              = "10.0.0.0/16"
public_subnet_cidrs   = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs  = ["10.0.101.0/24", "10.0.102.0/24"]
```

### Instance Type Options

**Development:**

- `t3.small` - 2 vCPU, 2 GB RAM (burstable)
- `t3.medium` - 2 vCPU, 4 GB RAM (burstable)

**General Purpose:**

- `t3.large` - 2 vCPU, 8 GB RAM
- `m5.large` - 2 vCPU, 8 GB RAM
- `m5.xlarge` - 4 vCPU, 16 GB RAM

**Compute Optimized:**

- `c5.large` - 2 vCPU, 4 GB RAM
- `c5.xlarge` - 4 vCPU, 8 GB RAM

**Cost Optimization:**
Enable spot instances:

```hcl
enable_spot_instances   = true
spot_instance_types     = ["t3.medium", "t3.large"]
spot_desired_node_count = 2
```

## What Gets Deployed

### Core Infrastructure

- **VPC**: Custom VPC with configurable CIDR
- **Subnets**: Public and private subnets across 2+ availability zones
- **NAT Gateways**: For private subnet internet access
- **Internet Gateway**: For public subnet internet access
- **Security Groups**: Control plane and worker node security groups

### Kubernetes Cluster

- **EKS Cluster**: AWS-managed Kubernetes control plane
- **Kubernetes Version**: Configurable (1.27+)
- **Node Groups**: Auto-scaling worker node groups
- **Spot Instances** (Optional): For cost optimization

### IAM & Security

- **IAM Roles**: Cluster and node IAM roles with appropriate policies
- **OIDC Provider**: For IRSA (IAM Roles for Service Accounts)
- **Security Groups**: Restrictive security group rules

### Monitoring & Logging

- **CloudWatch Logs**: Control plane logs (API, Audit, Authenticator, etc.)
- **CloudWatch Log Group**: Centralized logging for the cluster

## Post-Deployment

### Get Cluster Credentials

```bash
# Using the output command
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster

# Or use the Terraform output
aws eks update-kubeconfig \
  --region $(terraform output -raw aws_region) \
  --name $(terraform output -raw cluster_id)
```

### Verify Cluster

```bash
# Check cluster info
kubectl cluster-info

# List nodes
kubectl get nodes

# Check node resource usage
kubectl top nodes
```

### Deploy Sample Application

```bash
# Create test deployment
kubectl create deployment nginx --image=nginx:latest
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Watch LoadBalancer get external IP
kubectl get svc --watch
```

## Terraform Commands

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Format configuration
terraform fmt

# Plan changes
terraform plan

# Apply changes
terraform apply

# Destroy all resources
terraform destroy

# Show outputs
terraform output

# Show specific output
terraform output cluster_endpoint
```

## Cost Optimization

### 1. Use Spot Instances

Spot instances can save up to 90% on compute costs:

```hcl
enable_spot_instances   = true
spot_desired_node_count = 2
```

### 2. Right-size Instances

Choose appropriate instance types:

- Dev: `t3.small` or `t3.medium`
- Prod: `t3.large` or `m5.large`

### 3. Adjust Auto-scaling

Match your workload requirements:

```hcl
desired_node_count = 2
min_node_count     = 1
max_node_count     = 5
```

### 4. Enable Cluster Autoscaler

Deploy on the cluster for dynamic scaling based on pod requirements.

## Advanced Configuration

### SSH Key for Node Access

Create an EC2 key pair first:

```bash
aws ec2 create-key-pair --key-name eks-nodes --query 'KeyMaterial' --output text > eks-nodes.pem
chmod 600 eks-nodes.pem
```

Then configure in `terraform.tfvars`:

```hcl
ec2_ssh_key_name = "eks-nodes"
```

### Restrict Public API Access

For production, restrict public access:

```hcl
public_access_cidrs = ["YOUR_IP/32"]  # e.g., "203.0.113.42/32"
```

### Custom Kubernetes Version

Use newer/older Kubernetes versions:

```hcl
kubernetes_version = "1.29"  # or "1.27"
```

### Log Retention

Adjust CloudWatch log retention:

```hcl
log_retention_in_days = 30  # default is 7 days
```

## Troubleshooting

### Common Issues

**Issue**: "AccessDenied: User is not authorized"

- Verify AWS credentials: `aws sts get-caller-identity`
- Ensure IAM user/role has EKS, EC2, and IAM permissions

**Issue**: "Error: Unable to connect to cluster"

- Update kubeconfig: `aws eks update-kubeconfig --name CLUSTER_NAME --region REGION`
- Verify security group allows your IP

**Issue**: "Nodes not joining cluster"

- Check node security groups
- Verify subnet configuration
- Review CloudWatch logs: `/aws/eks/CLUSTER_NAME/cluster`

### View Logs

```bash
# List available log groups
aws logs describe-log-groups --query 'logGroups[].logGroupName'

# View cluster logs
aws logs tail /aws/eks/my-eks-cluster/cluster --follow

# Export logs
aws logs create-export-task \
  --log-group-name /aws/eks/my-eks-cluster/cluster \
  --from $(date -d '1 day ago' +%s)000 \
  --to $(date +%s)000 \
  --destination my-s3-bucket
```

## Cleanup

To destroy all resources:

```bash
terraform destroy
```

**Warning**: This will delete:

- EKS cluster
- VPC, subnets, NAT gateways
- Security groups
- IAM roles
- All running Kubernetes workloads

## Terraform State

The Terraform state files contain sensitive information. Protect them:

```bash
# Store state in remote backend (S3)
# Add to main.tf:
# terraform {
#   backend "s3" {
#     bucket         = "my-tf-state"
#     key            = "eks/terraform.tfstate"
#     region         = "us-east-1"
#     encrypt        = true
#     dynamodb_table = "terraform-locks"
#   }
# }

# Enable S3 versioning for backup
aws s3api put-bucket-versioning \
  --bucket my-tf-state \
  --versioning-configuration Status=Enabled
```

## Required IAM Permissions

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*", "eks:*", "iam:*", "logs:*", "cloudwatch:*", "sts:GetCallerIdentity"],
      "Resource": "*"
    }
  ]
}
```

## Useful Resources

- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
