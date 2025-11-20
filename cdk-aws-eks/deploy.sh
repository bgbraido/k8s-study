#!/bin/bash
# Deploy script for EKS cluster

set -e

CLUSTER_NAME=${1:-my-eks-cluster}
REGION=${2:-us-east-1}
ENVIRONMENT=${3:-dev}
DESIRED_NODES=${4:-3}

echo "=========================================="
echo "AWS EKS Cluster Deployment"
echo "=========================================="
echo "Cluster Name: $CLUSTER_NAME"
echo "Region: $REGION"
echo "Environment: $ENVIRONMENT"
echo "Desired Nodes: $DESIRED_NODES"
echo "=========================================="

# Check prerequisites
echo "Checking prerequisites..."
command -v aws >/dev/null 2>&1 || { echo "AWS CLI not found"; exit 1; }
command -v cdk >/dev/null 2>&1 || { echo "CDK not found"; exit 1; }
command -v node >/dev/null 2>&1 || { echo "Node.js not found"; exit 1; }

# Get account ID
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
echo "AWS Account ID: $ACCOUNT_ID"

# Install dependencies
echo "Installing dependencies..."
npm install

# Build TypeScript
echo "Building TypeScript..."
npm run build

# Bootstrap CDK (if needed)
echo "Bootstrapping CDK..."
cdk bootstrap aws://$ACCOUNT_ID/$REGION 2>/dev/null || true

# Deploy
echo "Deploying EKS cluster..."
cdk deploy \
  -c clusterName=$CLUSTER_NAME \
  -c region=$REGION \
  -c environment=$ENVIRONMENT \
  -c desiredNodeCount=$DESIRED_NODES \
  --require-approval never

# Configure kubectl
echo "Configuring kubectl..."
aws eks update-kubeconfig \
  --name $CLUSTER_NAME \
  --region $REGION

echo "=========================================="
echo "Deployment Complete!"
echo "=========================================="
echo "Cluster: $CLUSTER_NAME"
echo "Region: $REGION"
echo ""
echo "Next steps:"
echo "1. Verify cluster: kubectl cluster-info"
echo "2. Check nodes: kubectl get nodes"
echo "3. Deploy applications: kubectl apply -f <manifest>"
echo "=========================================="
