variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "eks-project"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = "my-eks-cluster"
  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]*[a-z0-9]$", var.cluster_name)) && length(var.cluster_name) <= 100
    error_message = "Cluster name must be lowercase alphanumeric with hyphens, max 100 characters."
  }
}

variable "kubernetes_version" {
  description = "Kubernetes version to use for the EKS cluster"
  type        = string
  default     = "1.28"
  validation {
    condition     = can(regex("^1\\.(2[7-9]|3[0-9])$", var.kubernetes_version))
    error_message = "Kubernetes version must be 1.27 or later."
  }
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24"]
}

variable "node_instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "node_disk_size" {
  description = "Disk size in GB for worker nodes"
  type        = number
  default     = 50
  validation {
    condition     = var.node_disk_size >= 20
    error_message = "Node disk size must be at least 20 GB."
  }
}

variable "desired_node_count" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 3
  validation {
    condition     = var.desired_node_count >= 1
    error_message = "Desired node count must be at least 1."
  }
}

variable "min_node_count" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
  validation {
    condition     = var.min_node_count >= 1
    error_message = "Minimum node count must be at least 1."
  }
}

variable "max_node_count" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 10
  validation {
    condition     = var.max_node_count >= var.min_node_count
    error_message = "Maximum node count must be >= minimum node count."
  }
}

variable "ec2_ssh_key_name" {
  description = "Name of EC2 SSH key pair for node access (optional)"
  type        = string
  default     = ""
}

variable "public_access_cidrs" {
  description = "CIDR blocks with access to the public Kubernetes API endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "log_retention_in_days" {
  description = "CloudWatch log retention in days"
  type        = number
  default     = 7
}

variable "enable_spot_instances" {
  description = "Enable spot instances for cost optimization"
  type        = bool
  default     = false
}

variable "spot_instance_types" {
  description = "Instance types for spot instances"
  type        = list(string)
  default     = ["t3.medium", "t3.large"]
}

variable "spot_desired_node_count" {
  description = "Desired number of spot worker nodes"
  type        = number
  default     = 2
}

variable "spot_min_node_count" {
  description = "Minimum number of spot worker nodes"
  type        = number
  default     = 0
}

variable "spot_max_node_count" {
  description = "Maximum number of spot worker nodes"
  type        = number
  default     = 5
}
