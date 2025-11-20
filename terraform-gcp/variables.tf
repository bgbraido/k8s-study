variable "project_id" {
  description = "GCP Project ID"
  type        = string
  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "Project ID must be a valid GCP project ID."
  }
}

variable "region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
  validation {
    condition     = can(regex("^[a-z]{2}-[a-z]+[0-9]$", var.region))
    error_message = "Region must be a valid GCP region."
  }
}

variable "cluster_name" {
  description = "Name of the GKE cluster"
  type        = string
  default     = "my-gke-cluster"
  validation {
    condition     = can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.cluster_name)) && length(var.cluster_name) <= 40
    error_message = "Cluster name must be lowercase alphanumeric with hyphens, max 40 characters."
  }
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

variable "initial_node_count" {
  description = "Initial number of nodes in the node pool"
  type        = number
  default     = 3
  validation {
    condition     = var.initial_node_count >= 1 && var.initial_node_count <= 100
    error_message = "Initial node count must be between 1 and 100."
  }
}

variable "min_node_count" {
  description = "Minimum number of nodes in the node pool"
  type        = number
  default     = 1
  validation {
    condition     = var.min_node_count >= 1
    error_message = "Minimum node count must be at least 1."
  }
}

variable "max_node_count" {
  description = "Maximum number of nodes in the node pool"
  type        = number
  default     = 10
  validation {
    condition     = var.max_node_count >= var.min_node_count
    error_message = "Maximum node count must be greater than or equal to minimum node count."
  }
}

variable "machine_type" {
  description = "Machine type for the nodes"
  type        = string
  default     = "e2-standard-4"
}

variable "disk_size_gb" {
  description = "Disk size in GB for each node"
  type        = number
  default     = 50
  validation {
    condition     = var.disk_size_gb >= 10
    error_message = "Disk size must be at least 10 GB."
  }
}

variable "preemptible" {
  description = "Use preemptible nodes (cheaper, can be interrupted)"
  type        = bool
  default     = false
}

variable "subnet_cidr" {
  description = "CIDR range for the subnet"
  type        = string
  default     = "10.0.0.0/20"
}

variable "pods_cidr" {
  description = "CIDR range for pods (secondary IP range)"
  type        = string
  default     = "10.4.0.0/14"
}

variable "services_cidr" {
  description = "CIDR range for services (secondary IP range)"
  type        = string
  default     = "10.0.16.0/20"
}

variable "source_ip_ranges" {
  description = "Source IP ranges allowed for SSH access"
  type        = string
  default     = "0.0.0.0/0"
}
