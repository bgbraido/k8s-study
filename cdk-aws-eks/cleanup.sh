#!/bin/bash
# Cleanup script for EKS cluster

set -e

CLUSTER_NAME=${1:-my-eks-cluster}

echo "=========================================="
echo "AWS EKS Cluster Cleanup"
echo "=========================================="
echo "Cluster Name: $CLUSTER_NAME"
echo "=========================================="
echo ""
echo "WARNING: This will delete:"
echo "- EKS cluster: $CLUSTER_NAME"
echo "- VPC, subnets, and security groups"
echo "- Node groups and EC2 instances"
echo "- All associated resources"
echo ""
read -p "Are you sure? (type 'yes' to confirm): " -r
echo ""
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo "Destroying CDK stack..."
cdk destroy --force

echo "=========================================="
echo "Cleanup Complete!"
echo "=========================================="
