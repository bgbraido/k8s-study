#!/bin/bash
# Development environment setup script

echo "=========================================="
echo "EKS CDK Development Environment Setup"
echo "=========================================="

# Check Node.js
echo "Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo "Node.js not found. Installing..."
    # macOS
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install node
    else
        echo "Please install Node.js from https://nodejs.org/"
        exit 1
    fi
fi

NODE_VERSION=$(node --version)
echo "✓ Node.js: $NODE_VERSION"

# Check npm
echo "Checking npm..."
NPM_VERSION=$(npm --version)
echo "✓ npm: $NPM_VERSION"

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

# Check CDK
echo "Checking AWS CDK..."
if ! command -v cdk &> /dev/null; then
    echo "AWS CDK not found. Installing globally..."
    npm install -g aws-cdk
fi

CDK_VERSION=$(cdk --version)
echo "✓ AWS CDK: $CDK_VERSION"

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

# Install project dependencies
echo ""
echo "Installing project dependencies..."
npm install

echo ""
echo "=========================================="
echo "Setup Complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Configure AWS credentials: aws configure"
echo "2. Review and customize cdk.json"
echo "3. Run deployment: ./deploy.sh [cluster-name] [region] [env]"
echo ""
echo "Example:"
echo "  ./deploy.sh my-cluster us-east-1 dev"
echo "=========================================="
