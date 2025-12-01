# -----------------------------------------------------
# Derived values: Map filenames -> full paths
# -----------------------------------------------------
locals {
  dashboard_paths = {
    for f in var.dashboards :
    f => "${path.module}/dashboards/${f}"
  }
}
