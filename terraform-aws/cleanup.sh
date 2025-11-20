#!/bin/bash
# Cleanup script for AWS EKS cluster

set -e

echo "=========================================="
echo "AWS EKS Cluster Cleanup"
echo "=========================================="
echo ""
echo "WARNING: This will delete:"
echo "- EKS cluster"
echo "- VPC, subnets, NAT gateways"
echo "- Security groups"
echo "- IAM roles"
echo "- All associated resources"
echo ""
read -p "Are you sure? (type 'yes' to confirm): " -r
echo ""
if [[ ! $REPLY =~ ^[Yy][Ee][Ss]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo "Destroying Terraform resources..."
terraform destroy -auto-approve

echo "=========================================="
echo "Cleanup Complete!"
echo "=========================================="
