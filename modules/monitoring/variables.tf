variable "cluster_name" {
  description = "EKS cluster name."
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for monitoring stack."
  type        = string
  default     = "monitoring"
}

variable "chart_version" {
  description = "kube-prometheus-stack Helm chart version."
  type        = string
  default     = "84.3.0"
}
