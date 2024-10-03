resource "azurerm_container_registry" "acr" {
  name                     = "${var.prefix}acr"
  resource_group_name      = var.rg_name
  location                 = var.rg_location
  sku                      = "Basic"
  tags                     = var.tags
}