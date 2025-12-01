variable "namespace" {
  description = "Namespace to install monitoring into"
  type        = string
  default     = "monitoring"
}

variable "cluster_name" {
  description = "EKS cluster name (for kubeconfig references if needed)"
  type        = string
}

variable "prometheus_chart_version" {
  description = "Optional pinned chart version for kube-prometheus-stack"
  type        = string
  default     = "47.7.0" # adjust if you want a different stable version
}

variable "grafana_chart_version" {
  description = "Optional pinned chart version for grafana"
  type        = string
  default     = "9.5.1" # adjust to a compatible chart
}

variable "dashboards" {
  description = "Map of dashboard name -> local path (relative to module) to load into grafana ConfigMap"
  type        = map(string)
  default     = {
    "gpu-triton-dashboard.json" = "${path.module}/dashboards/gpu-triton-dashboard.json"
    "triton-metrics.json"       = "${path.module}/dashboards/triton-metrics.json"
    "latency-dashboard.json"    = "${path.module}/dashboards/latency-dashboard.json"
    "gpu.json"                  = "${path.module}/dashboards/gpu.json"
  }
}

variable "slack_webhook_secret_name" {
  description = "Kubernetes secret name to hold Slack webhook (created by CI or manually)"
  type        = string
  default     = "alertmanager-slack"
}

variable "alertmanager_config_name" {
  description = "Name of the alertmanager secret to create"
  type        = string
  default     = "alertmanager-config"
}

