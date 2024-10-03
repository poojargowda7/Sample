resource "azurerm_log_analytics_workspace" "loganalytics" {
  name                = "${var.prefix}-log-analytics"
  location            = var.rg_location
  resource_group_name = var.rg_name
  sku                 = "PerGB2018"
  retention_in_days   = 730
  tags                = var.tags
}