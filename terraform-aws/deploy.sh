#!/bin/bash
# Deploy script for AWS EKS cluster

set -e

CLUSTER_NAME=${1:-my-eks-cluster}
REGION=${2:-us-east-1}
ENVIRONMENT=${3:-dev}

echo "=========================================="
echo "AWS EKS Cluster Deployment"
echo "=========================================="
echo "Cluster Name: $CLUSTER_NAME"
echo "Region: $REGION"
echo "Environment: $ENVIRONMENT"
echo "=========================================="

# Check prerequisites
echo "Checking prerequisites..."
command -v aws >/dev/null 2>&1 || { echo "AWS CLI not found"; exit 1; }
command -v terraform >/dev/null 2>&1 || { echo "Terraform not found"; exit 1; }
command -v kubectl >/dev/null 2>&1 || { echo "kubectl not found"; exit 1; }

# Verify AWS credentials
echo "Verifying AWS credentials..."
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account ID: $ACCOUNT_ID"

# Initialize Terraform
echo "Initializing Terraform..."
terraform init

# Validate configuration
echo "Validating Terraform configuration..."
terraform validate

# Create tfvars if it doesn't exist
if [ ! -f "terraform.tfvars" ]; then
    echo "Creating terraform.tfvars from example..."
    cp terraform.tfvars.example terraform.tfvars
    sed -i.bak "s/cluster_name = .*/cluster_name = \"$CLUSTER_NAME\"/" terraform.tfvars
    sed -i.bak "s/aws_region = .*/aws_region = \"$REGION\"/" terraform.tfvars
    sed -i.bak "s/environment = .*/environment = \"$ENVIRONMENT\"/" terraform.tfvars
    rm terraform.tfvars.bak
fi

# Plan
echo "Planning infrastructure..."
terraform plan -out=tfplan

# Apply
echo "Applying infrastructure..."
terraform apply tfplan

# Get cluster credentials
echo "Configuring kubectl..."
aws eks update-kubeconfig \
  --name $CLUSTER_NAME \
  --region $REGION

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo ""
echo "Cluster Information:"
terraform output

echo ""
echo "Next steps:"
echo "1. Verify cluster: kubectl cluster-info"
echo "2. Check nodes: kubectl get nodes"
echo "3. Deploy applications: kubectl apply -f <manifest>"
echo "=========================================="
