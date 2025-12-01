terraform {
  required_providers {
    helm = {
      source = "hashicorp/helm"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
    }
  }
}

locals {
  prometheus_values = file("${path.module}/values/prometheus-values.yaml")
  grafana_values    = file("${path.module}/values/grafana-values.yaml")
}

# -----------------------------------------------------
# 1. Namespace: monitoring
# -----------------------------------------------------
resource "kubernetes_namespace" "monitoring_ns" {
  metadata {
    name = var.namespace
  }
}

# -----------------------------------------------------
# 2. Prometheus Stack (Prometheus + Alertmanager)
# -----------------------------------------------------
resource "helm_release" "prometheus" {
  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring_ns.metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "58.3.0"

  values = [
    local.prometheus_values
  ]

  depends_on = [kubernetes_namespace.monitoring_ns]
}

# -----------------------------------------------------
# 3. Grafana Helm Chart
# -----------------------------------------------------
resource "helm_release" "grafana" {
  name       = "grafana"
  namespace  = kubernetes_namespace.monitoring_ns.metadata[0].name
  repository = "https://grafana.github.io/helm-charts"
  chart      = "grafana"
  version    = "6.57.4"

  values = [
    local.grafana_values
  ]

  depends_on = [helm_release.prometheus]
}

# -----------------------------------------------------
# 4. Create Alertmanager Slack secret from CICD pipeline
# -----------------------------------------------------
resource "kubernetes_secret" "alertmanager" {
  metadata {
    name      = "alertmanager-slack"
    namespace = kubernetes_namespace.monitoring_ns.metadata[0].name
  }

  data = {
    "alertmanager.yaml" = base64encode(var.alertmanager_config)
  }

  type = "Opaque"

  depends_on = [helm_release.prometheus]
}

# -----------------------------------------------------
# 5. Load dashboards into Grafana via ConfigMaps
# -----------------------------------------------------
resource "kubernetes_config_map" "grafana_dashboards" {
  for_each = local.dashboard_paths

  metadata {
    name      = trimsuffix(each.key, ".json")
    namespace = kubernetes_namespace.monitoring_ns.metadata[0].name
    labels = {
      grafana_dashboard = "1"
    }
  }

  data = {
    dashboard = file(each.value)
  }

  depends_on = [helm_release.grafana]
}

# -----------------------------------------------------
# 6. Apply Prometheus alert rules
# -----------------------------------------------------
resource "kubernetes_manifest" "prometheus_rules" {
  manifest = yamldecode(
    templatefile("${path.module}/manifests/prometheus-rules.yaml", {
      namespace = var.namespace
    })
  )

  depends_on = [helm_release.prometheus]
}

# -----------------------------------------------------
# 7. NVIDIA DCGM GPU Exporter
# -----------------------------------------------------
resource "helm_release" "nvidia_dcgm" {
  name       = "dcgm-exporter"
  namespace  = kubernetes_namespace.monitoring_ns.metadata[0].name
  repository = "https://nvidia.github.io/dcgm-exporter"
  chart      = "dcgm-exporter"
  version    = "3.1.8"

  set = [
    {
      name  = "serviceMonitor.enabled"
      value = "true"
    }
  ]

  depends_on = [
    helm_release.prometheus,
    helm_release.grafana
  ]
}
