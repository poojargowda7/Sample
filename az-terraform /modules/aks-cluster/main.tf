module "acr" {
  source                    = "../acr"
  prefix                    = var.prefix
  rg_name                   = var.rg_name
  rg_location               = var.location
  tags                      = var.tags
}

module "aks-network" {
  source                    = "../aks-network"
  rg_name                   = var.rg_name
  rg_location               = var.location
  prefix                    = var.prefix
  vnet_CIDR                 = var.vnet_CIDR
  subnet1-CIDR              = var.subnet1-CIDR
  subnet2-CIDR              = var.subnet2-CIDR
  subnet3-CIDR              = var.subnet3-CIDR
  subnet4-CIDR              = var.subnet4-CIDR
  tags                      = var.tags
}

module "application-gateway" {
  source                    = "../application-gateway"
  rg_name                   = var.rg_name
  rg_location               = var.location
  azurerm_vnet_name         = module.aks-network.azurerm_vnet_name
  azurerm_subnet_gateway_id = module.aks-network.azurerm_subnet_gateway_id
  azurerm_public_ip_id      = module.aks-network.azurerm_public_ip_id
  prefix                    = var.prefix
  tags                      = var.tags 
}

module "azure-log-analytics" {
  source                    = "../azure-log-analytics"
  prefix                    = var.prefix
  rg_name                   = var.rg_name
  rg_location               = var.location
  tags                      = var.tags
}

module "aks" {
  source                    = "../aks"
  rg_name                   = var.rg_name
  rg_location               = var.location
  prefix                    = var.prefix
  tags                      = var.tags 
  kubernetes_version        = var.kubernetes_version
  aks_vmss_sku              = var.aks_vmss_sku
  network_policy            = var.network_policy
  azure_policy              = var.azure_policy
  aad_tenant_id             = var.aad_tenant_id
  aad_admin_group_id        = var.aad_admin_group_id
  azurerm_subnet_app_id     = module.aks-network.azurerm_subnet_app_id
  azurerm_log_analytics_id  = module.azure-log-analytics.azurerm_log_analytics_id
  #cluster_id                = module.aks.aks_cluster_id
  azurerm_subnet_data_id    = module.aks-network.azurerm_subnet_data_id
  azurerm_subnet_web_id     = module.aks-network.azurerm_subnet_web_id
  app_node_count            = var.app_node_count
  app_max_count             = var.app_max_count
  app_min_count             = var.app_min_count
  app_max_pods              = var.app_max_pods
  app_availability_zones    = var.app_availability_zones
  data_node_count           = var.data_node_count
  data_max_count            = var.data_max_count
  data_min_count            = var.data_min_count
  data_max_pods             = var.data_max_pods
  data_availability_zones   = var.data_availability_zones
  web_node_count            = var.web_node_count
  web_max_count             = var.web_max_count
  web_min_count             = var.web_min_count
  web_max_pods              = var.web_max_pods
  web_availability_zones    = var.web_availability_zones

}