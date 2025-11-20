import * as cdk from "aws-cdk-lib";
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as eks from "aws-cdk-lib/aws-eks";
import * as iam from "aws-cdk-lib/aws-iam";
import { Construct } from "constructs";

export interface EksClusterStackProps extends cdk.StackProps {
  env?: cdk.Environment;
  environment: string;
  clusterName: string;
  vpcCidr: string;
  privateSubnetCidr1: string;
  privateSubnetCidr2: string;
  publicSubnetCidr1: string;
  publicSubnetCidr2: string;
  nodeInstanceType: string;
  minNodeCount: number;
  maxNodeCount: number;
  desiredNodeCount: number;
}

export class EksClusterStack extends cdk.Stack {
  public readonly cluster: eks.Cluster;
  public readonly vpc: ec2.Vpc;

  constructor(scope: Construct, id: string, props: EksClusterStackProps) {
    super(scope, id, props);

    // Create VPC
    this.vpc = new ec2.Vpc(this, "EksVpc", {
      cidr: props.vpcCidr,
      enableDns: true,
      enableDnsHostnames: true,
      maxAzs: 2,
      subnetConfiguration: [
        {
          cidrMask: 24,
          name: "public",
          subnetType: ec2.SubnetType.PUBLIC,
        },
        {
          cidrMask: 24,
          name: "private",
          subnetType: ec2.SubnetType.PRIVATE_WITH_NAT,
        },
      ],
      natGateways: 1,
      restrictDefaultSecurityGroup: true,
    });

    // Create security group for the cluster
    const clusterSecurityGroup = new ec2.SecurityGroup(this, "ClusterSecurityGroup", {
      vpc: this.vpc,
      description: "Security group for EKS cluster control plane",
      allowAllOutbound: true,
    });

    clusterSecurityGroup.addIngressRule(ec2.Peer.ipv4(props.vpcCidr), ec2.Port.tcp(443), "Allow HTTPS from VPC");

    // Create IAM role for EKS cluster
    const clusterRole = new iam.Role(this, "EksClusterRole", {
      assumedBy: new iam.ServicePrincipal("eks.amazonaws.com"),
      managedPolicies: [iam.ManagedPolicy.fromAwsManagedPolicyName("AmazonEKSClusterPolicy"), iam.ManagedPolicy.fromAwsManagedPolicyName("AmazonEKSVpcResourceController")],
    });

    // Create EKS Cluster
    this.cluster = new eks.Cluster(this, "EksCluster", {
      clusterName: props.clusterName,
      version: eks.KubernetesVersion.V1_28,
      vpc: this.vpc,
      vpcSubnets: [
        {
          subnetType: ec2.SubnetType.PRIVATE_WITH_NAT,
        },
      ],
      role: clusterRole,
      securityGroup: clusterSecurityGroup,
      endpointAccess: eks.EndpointAccess.PUBLIC_AND_PRIVATE,
      logging: {
        clusterLogging: [
          eks.ClusterLoggingTypes.API,
          eks.ClusterLoggingTypes.AUDIT,
          eks.ClusterLoggingTypes.AUTHENTICATOR,
          eks.ClusterLoggingTypes.CONTROLLER_MANAGER,
          eks.ClusterLoggingTypes.SCHEDULER,
        ],
      },
      defaultCapacity: 0, // We'll manage capacity with a node group
    });

    // Create IAM role for node group
    new iam.Role(this, "EksNodeRole", {
      assumedBy: new iam.ServicePrincipal("ec2.amazonaws.com"),
      managedPolicies: [
        iam.ManagedPolicy.fromAwsManagedPolicyName("AmazonEKSWorkerNodePolicy"),
        iam.ManagedPolicy.fromAwsManagedPolicyName("AmazonEKS_CNI_Policy"),
        iam.ManagedPolicy.fromAwsManagedPolicyName("AmazonEC2ContainerRegistryReadOnly"),
        iam.ManagedPolicy.fromAwsManagedPolicyName("CloudWatchAgentServerPolicy"),
      ],
    });

    // Create Node Group with auto-scaling
    const nodeGroup = this.cluster.addAutoScalingGroupCapacity("NodeGroup", {
      instanceType: ec2.InstanceType.of(ec2.InstanceClass.T3, ec2.InstanceSize.MEDIUM),
      desiredCapacity: props.desiredNodeCount,
      minCapacity: props.minNodeCount,
      maxCapacity: props.maxNodeCount,
      canContainerize: true,
      machineImage: eks.EksOptimizedImage.lookup({
        nodeType: eks.NodeType.STANDARD,
        kubernetesVersion: "1.28",
      }),
      spotPrice: "0.05", // Use spot instances for cost optimization
    });

    // Add tags to the node group
    cdk.Tags.of(nodeGroup).add("Environment", props.environment);
    cdk.Tags.of(nodeGroup).add("ManagedBy", "CDK");

    // Add cluster tags
    cdk.Tags.of(this.cluster).add("Environment", props.environment);
    cdk.Tags.of(this.cluster).add("ManagedBy", "CDK");
    cdk.Tags.of(this.vpc).add("Environment", props.environment);

    // Create outputs
    new cdk.CfnOutput(this, "ClusterName", {
      value: this.cluster.clusterName,
      description: "EKS Cluster Name",
      exportName: `${props.clusterName}-name`,
    });

    new cdk.CfnOutput(this, "ClusterArn", {
      value: this.cluster.clusterArn,
      description: "EKS Cluster ARN",
      exportName: `${props.clusterName}-arn`,
    });

    new cdk.CfnOutput(this, "ClusterEndpoint", {
      value: this.cluster.clusterEndpoint,
      description: "EKS Cluster Endpoint",
      exportName: `${props.clusterName}-endpoint`,
    });

    new cdk.CfnOutput(this, "ClusterSecurityGroupId", {
      value: this.cluster.clusterSecurityGroup.securityGroupId,
      description: "EKS Cluster Security Group ID",
      exportName: `${props.clusterName}-sg`,
    });

    new cdk.CfnOutput(this, "ConfigCommand", {
      value: `aws eks update-kubeconfig --region us-east-1 --name ${this.cluster.clusterName}`,
      description: "Command to configure kubectl",
    });
  }
}
