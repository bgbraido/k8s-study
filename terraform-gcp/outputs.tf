output "cluster_name" {
  description = "GKE Cluster Name"
  value       = google_container_cluster.kubernetes_cluster.name
}

output "cluster_host" {
  description = "Kubernetes cluster host"
  value       = google_container_cluster.kubernetes_cluster.endpoint
  sensitive   = true
}

output "region" {
  description = "GCP region"
  value       = var.region
}

output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "kubernetes_cluster_name" {
  description = "GKE Cluster Name"
  value       = google_container_cluster.kubernetes_cluster.name
  depends_on = [
    google_container_node_pool.primary_nodes
  ]
}

output "kubernetes_cluster_host" {
  description = "GKE Cluster Host"
  value       = google_container_cluster.kubernetes_cluster.endpoint
  sensitive   = true
  depends_on = [
    google_container_node_pool.primary_nodes
  ]
}

output "vpc_name" {
  description = "VPC Network name"
  value       = google_compute_network.vpc.name
}

output "subnet_name" {
  description = "Subnet name"
  value       = google_compute_subnetwork.subnet.name
}
