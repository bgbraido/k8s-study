#!/bin/bash
# Utility script to get cluster information

CLUSTER_NAME=${1:-$(terraform output -raw cluster_id)}
REGION=${2:-$(terraform output -raw aws_region)}

if [ -z "$CLUSTER_NAME" ]; then
    echo "Error: Cluster name not provided and could not be retrieved from Terraform output"
    exit 1
fi

echo "=========================================="
echo "EKS Cluster Information"
echo "=========================================="
echo ""

echo "Cluster Details:"
aws eks describe-cluster \
  --name $CLUSTER_NAME \
  --region $REGION \
  --query 'cluster.[name,status,version,endpoint,platformVersion]' \
  --output table

echo ""
echo "Cluster Nodes:"
kubectl get nodes -o wide

echo ""
echo "Cluster Info:"
kubectl cluster-info

echo ""
echo "Namespaces:"
kubectl get namespaces

echo ""
echo "Workloads:"
kubectl get all --all-namespaces

echo ""
echo "Storage Classes:"
kubectl get storageclass

echo ""
echo "=========================================="
