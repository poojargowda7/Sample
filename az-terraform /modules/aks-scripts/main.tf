resource "azurerm_kubernetes_cluster_node_pool" "data" {
  name                  = "data"
  kubernetes_cluster_id = var.cluster_id
  vm_size               = var.aks_vmss_sku
  enable_auto_scaling   = true
  node_count            = 1
  max_count             = 2
  min_count             = 1
  max_pods              = 75
  availability_zones    = [ "1", "2", "3" ]
  vnet_subnet_id        = var.azurerm_subnet_data_id
  tags                  = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "web" {
  name                  = "web"
  kubernetes_cluster_id = var.cluster_id
  vm_size               = var.aks_vmss_sku
  enable_auto_scaling   = true
  node_count            = 1
  max_count             = 2
  min_count             = 1
  max_pods              = 75
  vnet_subnet_id        = var.azurerm_subnet_web_id
  availability_zones    = [ "1", "2", "3" ]
  tags                  = var.tags
}



resource "null_resource" "add-agic" {
  provisioner "local-exec" {
    command = "az aks enable-addons -n ${var.aks_cluster_name} -g ${var.rg_name} -a ingress-appgw --appgw-id ${var.application_gateway_network_id}"
  }
  depends_on = [azurerm_kubernetes_cluster_node_pool.data, azurerm_kubernetes_cluster_node_pool.web]
}

resource "null_resource" "attach-acr" {
  provisioner "local-exec" {
    command = "az aks update -n ${var.aks_cluster_name} -g ${var.rg_name} --attach-acr ${var.acr_name}"
  }
  depends_on = [null_resource.add-agic]
}

resource "null_resource" "agic-identity-linux" {
  provisioner "local-exec" {
    command = <<EOT
      $CLIENTID=(az aks show -n ${var.aks_cluster_name} -g ${var.rg_name} --query "addonProfiles.ingressApplicationGateway.identity.clientId")
      az role assignment create --role Reader --scope ${var.rg_id} --assignee $CLIENTID
      az role assignment create --role Contributor --scope ${var.application_gateway_network_id} --assignee $CLIENTID
    EOT
    interpreter = ["pwsh", "-Command"]
  }
  count = var.environment == "0" ? "1" : "0"
  depends_on = [null_resource.attach-acr]
}


resource "null_resource" "agic-identity-windows" {
  provisioner "local-exec" {
    command = <<EOT
      $CLIENTID=(az aks show -n ${var.aks_cluster_name} -g ${var.rg_name} --query "addonProfiles.ingressApplicationGateway.identity.clientId")
      az role assignment create --role Reader --scope ${var.rg_id} --assignee $CLIENTID
      az role assignment create --role Contributor --scope ${var.application_gateway_network_id} --assignee $CLIENTID
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
  count = var.environment == "1" ? "1" : "0"
  depends_on = [null_resource.attach-acr]
}