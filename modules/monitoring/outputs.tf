output "namespace" {
  description = "Monitoring namespace."
  value       = var.namespace
}

output "grafana_service_name" {
  description = "Grafana service name."
  value       = "monitoring-grafana"
}

output "prometheus_service_name" {
  description = "Prometheus service name."
  value       = "monitoring-kube-prometheus-prometheus"
}
