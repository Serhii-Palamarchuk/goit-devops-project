variable "cluster_name" {
  description = "EKS cluster name where Argo CD will be installed"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace for Argo CD"
  type        = string
  default     = "argocd"
}

variable "chart_version" {
  description = "Argo CD Helm chart version"
  type        = string
  default     = "9.1.1"
}
