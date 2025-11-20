#!/bin/bash
# Utility script to get cluster information

CLUSTER_NAME=${1:-my-eks-cluster}
REGION=${2:-us-east-1}

echo "=========================================="
echo "EKS Cluster Information"
echo "=========================================="

# Get cluster info
echo "Cluster Details:"
aws eks describe-cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --query 'cluster.[name,status,version,endpoint]' \
  --output table

echo ""
echo "Cluster Nodes:"
kubectl get nodes -o wide

echo ""
echo "Cluster Info:"
kubectl cluster-info

echo ""
echo "Cluster Resources:"
kubectl get all --all-namespaces

echo ""
echo "Storage Classes:"
kubectl get storageclass

echo ""
echo "=========================================="
