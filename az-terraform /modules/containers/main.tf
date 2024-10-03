provider "azurerm" {
  features {}
}

locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet.name}-rqrt"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-containers-rg"
  location = var.location
  tags     = var.tags
}

resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Basic"
  tags                     = var.tags
}

#Virtual Network with 4 tier subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-network"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.1.0.0/22"]
}

resource "azurerm_subnet" "app" {
  name                 = "app"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.0.0/24"]
}

resource "azurerm_subnet" "data" {
  name                 = "data"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_subnet" "web" {
  name                 = "web"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.2.0/24"]
}

resource "azurerm_subnet" "gateway" {
  name                 = "gateway"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = azurerm_resource_group.rg.name
  address_prefixes     = ["10.1.3.0/24"]
}

resource "azurerm_public_ip" "publicIp" {
  name                         = "gatewayPublicIp"
  location                     = azurerm_resource_group.rg.location
  resource_group_name          = azurerm_resource_group.rg.name
  allocation_method            = "Static"
  sku                          = "Standard"
  tags                         = var.tags
}

resource "azurerm_application_gateway" "network" {
  name                = var.app_gateway_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  zones               = [ "1", "2", "3" ]

  autoscale_configuration {
    min_capacity     = 2
    max_capacity     = 3
  }

  sku {
    name     = var.app_gateway_sku
    tier     = var.app_gateway_sku
  }

  gateway_ip_configuration {
    name      = "appGatewayIpConfig"
    subnet_id = azurerm_subnet.gateway.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "httpsPort"
    port = 443
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.publicIp.id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }


  waf_configuration {
    enabled                  = var.waf_enabled
    firewall_mode            = coalesce(var.waf_configuration != null ? var.waf_configuration.firewall_mode : null, "Prevention")
    rule_set_type            = coalesce(var.waf_configuration != null ? var.waf_configuration.rule_set_type : null, "OWASP")
    rule_set_version         = coalesce(var.waf_configuration != null ? var.waf_configuration.rule_set_version : null, "3.1")
    file_upload_limit_mb     = coalesce(var.waf_configuration != null ? var.waf_configuration.file_upload_limit_mb : null, 100)
    max_request_body_size_kb = coalesce(var.waf_configuration != null ? var.waf_configuration.max_request_body_size_kb : null, 128)
  }


  tags = var.tags

  depends_on = [
    azurerm_virtual_network.vnet,
    azurerm_public_ip.publicIp,
  ]
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "${var.prefix}-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${var.prefix}-aks"
  tags                = var.tags
  kubernetes_version = var.kubernetes_version
  #os_type             = var.aks_vmss_os

  default_node_pool {
    name                = "app"
    enable_auto_scaling = true
    node_count          = 1
    max_count           = 2
    min_count           = 1
    max_pods            = 75
    vm_size             = var.aks_vmss_sku
    vnet_subnet_id      = azurerm_subnet.app.id

    availability_zones  = [ "1", "2", "3" ]
  }

  network_profile {
    network_plugin = "azure"
    network_policy = "calico"
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
      enabled = true
    }

    http_application_routing {
      enabled = false
    }

    kube_dashboard {
      enabled = false
    }

    oms_agent {
      enabled                    = true
      log_analytics_workspace_id = var.log_analytics_workspace_id
    }
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "data" {
  name                  = "data"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.aks_vmss_sku
  enable_auto_scaling   = true
  node_count            = 1
  max_count             = 2
  min_count             = 1
  max_pods              = 75
  availability_zones    = [ "1", "2", "3" ]
  vnet_subnet_id        = azurerm_subnet.data.id
  tags                  = var.tags
}

resource "azurerm_kubernetes_cluster_node_pool" "web" {
  name                  = "web"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks.id
  vm_size               = var.aks_vmss_sku
  enable_auto_scaling   = true
  node_count            = 1
  max_count             = 2
  min_count             = 1
  max_pods              = 75
  vnet_subnet_id        = azurerm_subnet.web.id
  availability_zones    = [ "1", "2", "3" ]
  tags                  = var.tags
}

provider "null" {
  version = ">=2.1"
}

resource "null_resource" "attach-acr" {
  provisioner "local-exec" {
    command = "az aks update -n ${azurerm_kubernetes_cluster.aks.name} -g ${azurerm_resource_group.rg.name} --attach-acr ${azurerm_container_registry.acr.name}"
  }
  depends_on = [azurerm_resource_group.rg, azurerm_container_registry.acr, azurerm_kubernetes_cluster.aks, azurerm_kubernetes_cluster_node_pool.data, azurerm_kubernetes_cluster_node_pool.web]
}

resource "null_resource" "add-agic" {
  provisioner "local-exec" {
    command = "az aks enable-addons -n ${azurerm_kubernetes_cluster.aks.name} -g ${azurerm_resource_group.rg.name} -a ingress-appgw --appgw-id ${azurerm_application_gateway.network.id}"
  }
  depends_on = [azurerm_application_gateway.network, null_resource.attach-acr]
}

resource "null_resource" "agic-identity" {
  provisioner "local-exec" {
    command = <<EOT
      $CLIENTID=(az aks show -n ${azurerm_kubernetes_cluster.aks.name} -g ${azurerm_resource_group.rg.name} --query "addonProfiles.ingressApplicationGateway.identity.clientId")
      az role assignment create --role Reader --scope ${azurerm_resource_group.rg.id} --assignee $CLIENTID
      az role assignment create --role Contributor --scope ${azurerm_application_gateway.network.id} --assignee $CLIENTID
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
  depends_on = [azurerm_resource_group.rg, azurerm_application_gateway.network, azurerm_kubernetes_cluster.aks, null_resource.add-agic]
}