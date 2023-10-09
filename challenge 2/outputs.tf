output "installed_charts" {
  value = [for chart in var.charts : chart.chart_name]
  description = "List of installed Helm charts."
}