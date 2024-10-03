output "aks_cluster_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "client_key" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_key
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.client_certificate
}

output "cluster_ca_certificate" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.cluster_ca_certificate
}

output "host" {
  value = azurerm_kubernetes_cluster.aks.kube_admin_config.0.host
}
