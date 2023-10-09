# Assuming you have already authenticated with Azure
provider "azurerm" {
  features {}
}

# Iterate over each chart for import and installation
resource "null_resource" "import_and_install_chart" {
  for_each = { for chart in var.charts : chart.chart_name => chart }

  # Use a local-exec provisioner to run a hypothetical script to import charts
  provisioner "local-exec" {
    command = "./import_chart.sh ${var.source_acr_server} ${var.source_acr_client_id} ${var.source_acr_client_secret} ${var.acr_server} ${each.value.chart_name} ${each.value.chart_version}"
  }
}

resource "helm_release" "chart" {
  for_each = { for chart in var.charts : chart.chart_name => chart }

  name       = each.value.chart_name
  repository = each.value.chart_repository
  chart      = each.value.chart_name
  version    = each.value.chart_version
  namespace  = each.value.chart_namespace

  set {
    name  = each.value.values.name
    value = each.value.values.value
  }

  set_sensitive {
    name  = each.value.sensitive_values.name
    value = each.value.sensitive_values.value
  }

  depends_on = [null_resource.copy_charts]
}