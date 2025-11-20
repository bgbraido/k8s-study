# AWS EKS Cluster Deployment with CDK TypeScript

This directory contains AWS CDK TypeScript configuration to deploy a production-ready Amazon EKS (Elastic Kubernetes Service) cluster on AWS.

## Prerequisites

1. **AWS Account**: Create and configure an AWS account
2. **AWS CLI**: Install [AWS CLI v2](https://aws.amazon.com/cli/)
3. **Node.js**: Install [Node.js](https://nodejs.org/) >= 16.x
4. **AWS CDK**: Install CDK CLI: `npm install -g aws-cdk`
5. **kubectl**: Install [kubectl](https://kubernetes.io/docs/tasks/tools/)

## Quick Start

### 1. Install Dependencies

```bash
cd cdk-aws-eks
npm install
```

### 2. Configure AWS Credentials

```bash
aws configure
# or set environment variables:
export AWS_ACCESS_KEY_ID=your-access-key
export AWS_SECRET_ACCESS_KEY=your-secret-key
export AWS_DEFAULT_REGION=us-east-1
```

### 3. Bootstrap CDK (First Time Only)

```bash
cdk bootstrap aws://ACCOUNT_ID/REGION
# Example:
cdk bootstrap aws://123456789012/us-east-1
```

To get your account ID:

```bash
aws sts get-caller-identity --query Account --output text
```

### 4. Build and Deploy

```bash
# Build TypeScript
npm run build

# Review infrastructure changes
cdk diff

# Deploy the cluster
cdk deploy

# Or deploy with custom parameters:
cdk deploy -c clusterName=prod-cluster -c desiredNodeCount=5
```

## Configuration

### Environment Variables and Context

Configure the cluster via `cdk.json` or command-line context:

```bash
cdk deploy \
  -c clusterName=my-cluster \
  -c region=us-west-2 \
  -c desiredNodeCount=5 \
  -c maxNodeCount=10 \
  -c environment=prod
```

### Available Configuration Options

| Parameter          | Default          | Description                           |
| ------------------ | ---------------- | ------------------------------------- |
| `clusterName`      | `my-eks-cluster` | Name of the EKS cluster               |
| `region`           | `us-east-1`      | AWS region                            |
| `environment`      | `dev`            | Environment name (dev, staging, prod) |
| `vpcCidr`          | `10.0.0.0/16`    | VPC CIDR block                        |
| `nodeInstanceType` | `t3.medium`      | EC2 instance type for nodes           |
| `minNodeCount`     | `2`              | Minimum nodes in auto-scaling group   |
| `maxNodeCount`     | `6`              | Maximum nodes in auto-scaling group   |
| `desiredNodeCount` | `3`              | Desired number of nodes               |

### Instance Type Options

- **Development**: `t3.small`, `t3.medium` (burstable, cost-effective)
- **General Purpose**: `t3.large`, `m5.large`, `m5.xlarge`
- **High Performance**: `c5.large`, `c5.xlarge`, `c5.2xlarge`
- **Memory Optimized**: `r5.large`, `r5.xlarge`, `r5.2xlarge`

## What Gets Deployed

The CDK stack creates:

1. **VPC Network**

   - Custom VPC with configurable CIDR
   - Public subnets across 2 availability zones
   - Private subnets with NAT gateway
   - VPC flow logs for monitoring

2. **EKS Cluster**

   - Kubernetes version 1.28
   - Public and private endpoint access
   - Cluster autoscaling enabled
   - CloudWatch logging for control plane

3. **Node Group**

   - Auto-scaling group with desired/min/max capacity
   - EKS-optimized Amazon Linux 2 AMI
   - Spot instances for cost optimization
   - CloudWatch agent pre-installed

4. **Security**

   - IAM roles and policies for cluster and nodes
   - Security groups with restricted access
   - VPC endpoints for private connectivity

5. **Monitoring**
   - CloudWatch Logs for cluster activity
   - Control plane logs enabled
   - CloudWatch agent on nodes

## Post-Deployment

### Get Cluster Credentials

After deployment, configure kubectl:

```bash
# Use the output command from cdk deploy
aws eks update-kubeconfig --region us-east-1 --name my-eks-cluster
```

Or manually:

```bash
aws eks update-kubeconfig \
  --name $(cdk output ClusterName) \
  --region $(aws configure get region)
```

### Verify Cluster

```bash
# Check cluster status
kubectl cluster-info

# View nodes
kubectl get nodes

# View all resources
kubectl get all --all-namespaces
```

### Deploy Sample Application

```bash
# Create a test deployment
kubectl create deployment nginx --image=nginx:latest
kubectl expose deployment nginx --port=80 --type=LoadBalancer

# Check service
kubectl get svc
```

## CDK Commands

```bash
# Build TypeScript
npm run build

# Watch mode (auto-compile)
npm run watch

# View infrastructure changes
cdk diff

# Deploy the stack
cdk deploy

# Destroy all resources
cdk destroy

# Synthesize CloudFormation template
cdk synth

# View available stacks
cdk list

# Get stack outputs
cdk output
```

## Customization

### Add OIDC Provider for IRSA

To enable IAM Roles for Service Accounts (IRSA):

```typescript
const oidcProvider = cluster.openIdConnectProvider;

const serviceAccountRole = new iam.Role(this, "ServiceAccountRole", {
  assumedBy: new iam.FederatedPrincipal(
    oidcProvider.openIdConnectProviderArn,
    {
      StringEquals: {
        [`${oidcProvider.openIdConnectProviderIssuer}:sub`]: "system:serviceaccount:default:my-sa",
      },
    },
    "sts:AssumeRoleWithWebIdentity"
  ),
});
```

### Add Managed Node Groups

```typescript
cluster.addNodegroupCapacity("ManagedNodeGroup", {
  desiredSize: 3,
  minSize: 1,
  maxSize: 10,
  diskSize: 100,
  machineType: ec2.InstanceType.of(ec2.InstanceClass.T3, ec2.InstanceSize.MEDIUM),
});
```

### Enable Add-ons

```typescript
cluster.addServiceAccount("aws-ebs-csi-driver", {
  namespace: "kube-system",
});

cluster.addHelmChart("ebs-csi-driver", {
  chart: "aws-ebs-csi-driver",
  namespace: "kube-system",
  values: {
    // configuration
  },
});
```

## Cost Optimization

1. **Use Spot Instances**: Already enabled in the configuration

   ```bash
   cdk deploy -c spotPrice=0.05  # Set max spot price
   ```

2. **Right-size Instance Types**: Use smaller instances for dev/test

   ```bash
   cdk deploy -c nodeInstanceType=t3.small
   ```

3. **Adjust Auto-scaling**: Match your workload needs

   ```bash
   cdk deploy -c minNodeCount=1 -c maxNodeCount=5
   ```

4. **Enable Cluster Autoscaler**: For dynamic scaling

## Troubleshooting

### IAM Permissions Required

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": ["ec2:*", "eks:*", "iam:*", "logs:*", "cloudformation:*"],
      "Resource": "*"
    }
  ]
}
```

### Common Issues

**Issue**: "User: arn:aws:iam::... is not authorized"

- Ensure IAM user has sufficient permissions
- Run `aws sts get-caller-identity` to verify credentials

**Issue**: "Cannot pull image from ECR"

- Cluster nodes need ECR read permissions (already included)
- Verify image URI is correct

**Issue**: "Nodes not joining cluster"

- Check security group rules
- Verify VPC subnet configuration
- Check CloudWatch logs for node issues

## Monitoring and Logging

### View Control Plane Logs

```bash
aws logs describe-log-groups \
  --log-group-name-prefix /aws/eks/my-eks-cluster/

aws logs tail /aws/eks/my-eks-cluster/cluster --follow
```

### Monitor Node Performance

```bash
# Check node status
kubectl top nodes

# Check pod resource usage
kubectl top pods --all-namespaces
```

## Cleanup

To delete all resources:

```bash
cdk destroy

# Confirm deletion when prompted
```

**Warning**: This will delete the cluster and all associated resources. Ensure you've backed up any important data.

## Additional Resources

- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/)
- [AWS EKS Documentation](https://docs.aws.amazon.com/eks/)
- [EKS Best Practices Guide](https://aws.github.io/aws-eks-best-practices/)
- [CDK Workshop](https://cdkworkshop.com/)
