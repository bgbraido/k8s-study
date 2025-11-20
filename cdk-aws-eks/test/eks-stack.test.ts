import * as cdk from "aws-cdk-lib";
import { Template } from "aws-cdk-lib/assertions";
import { EksClusterStack } from "../src/eks-stack";

describe("EKS Cluster Stack", () => {
  let app: cdk.App;
  let stack: EksClusterStack;

  beforeEach(() => {
    app = new cdk.App();
    stack = new EksClusterStack(app, "TestStack", {
      environment: "test",
      clusterName: "test-cluster",
      vpcCidr: "10.0.0.0/16",
      privateSubnetCidr1: "10.0.1.0/24",
      privateSubnetCidr2: "10.0.2.0/24",
      publicSubnetCidr1: "10.0.101.0/24",
      publicSubnetCidr2: "10.0.102.0/24",
      nodeInstanceType: "t3.medium",
      minNodeCount: 2,
      maxNodeCount: 6,
      desiredNodeCount: 3,
    });
  });

  test("Creates VPC", () => {
    const template = Template.fromStack(stack);
    template.resourceCountIs("AWS::EC2::VPC", 1);
  });

  test("Creates EKS Cluster", () => {
    const template = Template.fromStack(stack);
    template.resourceCountIs("AWS::EKS::Cluster", 1);
  });

  test("Creates Node Group", () => {
    const template = Template.fromStack(stack);
    template.resourceCountIs("AWS::AutoScaling::AutoScalingGroup", 1);
  });

  test("Creates IAM Roles", () => {
    const template = Template.fromStack(stack);
    template.resourceCountIs("AWS::IAM::Role", 2);
  });

  test("Outputs are defined", () => {
    const template = Template.fromStack(stack);
    template.hasOutput("ClusterName", {});
    template.hasOutput("ClusterArn", {});
    template.hasOutput("ClusterEndpoint", {});
  });
});
