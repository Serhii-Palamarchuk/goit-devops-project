resource "kubernetes_namespace_v1" "monitoring" {
  metadata {
    name = var.namespace
  }
}

resource "helm_release" "kube_prometheus_stack" {
  name      = "monitoring"
  namespace = kubernetes_namespace_v1.monitoring.metadata[0].name

  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = var.chart_version

  values = [
    file("${path.module}/values.yaml")
  ]

  timeout = 900

  depends_on = [
    kubernetes_namespace_v1.monitoring
  ]
}
