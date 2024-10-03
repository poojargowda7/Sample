resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = var.rg_location
  resource_group_name = var.rg_name
  dns_prefix          = "${var.prefix}-aks"
  tags                = var.tags
  kubernetes_version  = var.kubernetes_version
  #os_type             = var.aks_vmss_os
  automatic_channel_upgrade = "stable"

  default_node_pool {
    name                = "app"
    enable_auto_scaling = true
    node_count          = var.app_node_count
    max_count           = var.app_max_count
    min_count           = var.app_min_count
    max_pods            = var.app_max_pods
    vm_size             = var.aks_vmss_sku
    vnet_subnet_id      = var.azurerm_subnet_app_id
    availability_zones  = var.app_availability_zones
  }

  network_profile {
    network_plugin = "azure"
    network_policy = var.network_policy == "0" ? "azure" : "calico"
    load_balancer_sku = "standard"
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control {
    enabled = true
    azure_active_directory {
      managed                 = true
      tenant_id               = var.aad_tenant_id
      admin_group_object_ids  = [ var.aad_admin_group_id ]
      # V1 or legacy way of AAD connection
      # client_app_id:
      # server_app_id:
    }
  }

  addon_profile {

    aci_connector_linux {
      enabled = false
    }

    azure_policy {
      enabled = var.azure_policy == "0" ? true : false
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = false
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.azurerm_log_analytics_id
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "data" {
  name                  = "data"
  #kubernetes_cluster_id = var.cluster_id
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.aks_vmss_sku
  enable_auto_scaling   = true
  node_count            = var.data_node_count
  max_count             = var.data_max_count
  min_count             = var.data_min_count
  max_pods              = var.data_max_pods
  availability_zones    = var.data_availability_zones
  vnet_subnet_id        = var.azurerm_subnet_data_id
  tags                  = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "web" {
  name                  = "web"
  #kubernetes_cluster_id = var.cluster_id
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.aks_vmss_sku
  enable_auto_scaling   = true
  node_count            = var.web_node_count
  max_count             = var.web_max_count
  min_count             = var.web_min_count
  max_pods              = var.web_max_pods
  vnet_subnet_id        = var.azurerm_subnet_web_id
  availability_zones    = var.web_availability_zones
}