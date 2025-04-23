# K8s-monitoring Module - Installs and configures k8s-monitoring using Helm

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace to deploy k8s-monitoring into"
  type        = string
  default     = "k8s-monitoring"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
}

# Check if namespace already exists
data "kubernetes_namespace_v1" "k8s_monitoring" {
  metadata {
    name = var.namespace
  }
}

# Create namespace for k8s-monitoring only if it doesn't exist
resource "kubernetes_namespace" "k8s_monitoring" {
  count = length(data.kubernetes_namespace_v1.k8s_monitoring) > 0 ? 0 : 1
  
  metadata {
    name = var.namespace
    labels = merge(
      {
        name = var.namespace
        "app.kubernetes.io/managed-by" = "terraform"
        "app.kubernetes.io/part-of"    = var.cluster_name
      },
      var.tags
    )
  }
}

# Install k8s-monitoring chart using Helm
resource "helm_release" "k8s_monitoring" {
  name       = "k8s-monitoring"  # Use a unique name to avoid conflicts
  chart      = "${path.module}"
  namespace  = var.namespace  # Use the namespace variable directly since we know it exists
  timeout    = 600
  wait       = true
  atomic     = true
  max_history = 5
  force_update = true  # Force update to handle existing releases
  replace     = true  # Replace the release if it exists
  recreate_pods = true  # Recreate pods for StatefulSets to apply changes
  
  # Skip creating this resource if it already exists
  count = 1
  
  # Add lifecycle block to prevent destroy operations
  lifecycle {
    ignore_changes = [
      name,
      namespace,
      repository,
      chart,
      version,
    ]
  }
  
  # Use StatefulSet instead of Deployment for predictable pod naming
  set {
    name  = "prometheusAgent.statefulSet.enabled"
    value = "true"
  }
  
  set {
    name  = "nodeExporter.statefulSet.enabled"
    value = "true"
  }
  
  set {
    name  = "grafanaAgent.statefulSet.enabled"
    value = "true"
  }
  
  # Configure persistence using gp2 storage class for better compatibility
  set {
    name  = "prometheusAgent.persistentVolume.enabled"
    value = "true"
  }
  
  set {
    name  = "prometheusAgent.persistentVolume.storageClass"
    value = "gp2"
  }
  
  set {
    name  = "prometheusAgent.persistentVolume.size"
    value = "20Gi"
  }
  
  # Add cluster name to resources
  set {
    name  = "global.clusterName"
    value = var.cluster_name
  }
}

# Output the namespace for reference
output "namespace" {
  description = "The namespace where k8s-monitoring is deployed"
  value       = var.namespace
}

# Output the release name for reference
output "release_name" {
  description = "The name of the Helm release"
  value       = helm_release.k8s_monitoring[0].name
}
