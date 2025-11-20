#!/bin/bash
# Development environment setup script for Terraform AWS EKS

echo "=========================================="
echo "AWS EKS Terraform Environment Setup"
echo "=========================================="

# Check Terraform
echo "Checking Terraform..."
if ! command -v terraform &> /dev/null; then
    echo "Terraform not found. Installing..."
    # macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install terraform
    else
        echo "Please install Terraform from https://www.terraform.io/downloads"
        exit 1
    fi
fi

TERRAFORM_VERSION=$(terraform version | head -n 1)
echo "✓ $TERRAFORM_VERSION"

# Check AWS CLI
echo "Checking AWS CLI..."
if ! command -v aws &> /dev/null; then
    echo "AWS CLI not found. Installing..."
    # macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install awscli
    else
        echo "Please install AWS CLI from https://aws.amazon.com/cli/"
        exit 1
    fi
fi

AWS_VERSION=$(aws --version)
echo "✓ AWS CLI: $AWS_VERSION"

# Check kubectl
echo "Checking kubectl..."
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found. Installing..."
    # macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install kubectl
    else
        echo "Please install kubectl from https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
fi

KUBECTL_VERSION=$(kubectl version --client --short 2>/dev/null)
echo "✓ kubectl: $KUBECTL_VERSION"

# Verify AWS credentials
echo ""
echo "Verifying AWS credentials..."
if aws sts get-caller-identity &> /dev/null; then
    ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    IDENTITY=$(aws sts get-caller-identity --query Arn --output text)
    echo "✓ AWS Account: $ACCOUNT_ID"
    echo "✓ AWS Identity: $IDENTITY"
else
    echo "⚠ AWS credentials not configured"
    echo "Run 'aws configure' to set up your credentials"
fi

# Initialize Terraform
echo ""
echo "Initializing Terraform..."
terraform init

# Validate configuration
echo "Validating Terraform configuration..."
if terraform validate; then
    echo "✓ Terraform configuration is valid"
else
    echo "✗ Terraform configuration validation failed"
    exit 1
fi

# Format Terraform files
echo "Formatting Terraform files..."
terraform fmt -recursive

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Review and customize terraform.tfvars"
echo "2. Run 'terraform plan' to see planned changes"
echo "3. Run 'terraform apply' to deploy the cluster"
echo ""
echo "Or use the convenience script:"
echo "  ./deploy.sh [cluster-name] [region] [environment]"
echo ""
echo "Example:"
echo "  ./deploy.sh my-cluster us-east-1 dev"
echo "=========================================="
