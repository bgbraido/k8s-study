import * as cdk from "aws-cdk-lib";
import { EksClusterStack } from "./eks-stack";

const app = new cdk.App();

const env = {
  region: app.node.tryGetContext("region") || "us-east-1",
};

new EksClusterStack(app, "EksClusterStack", {
  env,
  environment: app.node.tryGetContext("environment") || "dev",
  clusterName: app.node.tryGetContext("clusterName") || "my-eks-cluster",
  vpcCidr: app.node.tryGetContext("vpcCidr") || "10.0.0.0/16",
  privateSubnetCidr1: app.node.tryGetContext("privateSubnetCidr1") || "10.0.1.0/24",
  privateSubnetCidr2: app.node.tryGetContext("privateSubnetCidr2") || "10.0.2.0/24",
  publicSubnetCidr1: app.node.tryGetContext("publicSubnetCidr1") || "10.0.101.0/24",
  publicSubnetCidr2: app.node.tryGetContext("publicSubnetCidr2") || "10.0.102.0/24",
  nodeInstanceType: app.node.tryGetContext("nodeInstanceType") || "t3.medium",
  minNodeCount: app.node.tryGetContext("minNodeCount") || 2,
  maxNodeCount: app.node.tryGetContext("maxNodeCount") || 6,
  desiredNodeCount: app.node.tryGetContext("desiredNodeCount") || 3,
});
