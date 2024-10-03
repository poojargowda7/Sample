data "azurerm_resource_group" "rg" {
  name                = var.existing_rg_name
}

data "azurerm_virtual_network" "vnet" {
  name                = var.existing_vnet_name
  resource_group_name = data.azurerm_resource_group.rg.name
}

data "azurerm_subnet" "sn" {
  name                = "default"
  resource_group_name = data.azurerm_resource_group.rg.name
  virtual_network_name = data.azurerm_virtual_network.vnet.name

}