#Virtual Network with 4 tier subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = var.rg_location
  resource_group_name = var.rg_name
  address_space       = var.vnet_CIDR
  tags                     = var.tags
}

resource "azurerm_subnet" "app" {
  name                 = "app"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg_name
  address_prefixes     = var.subnet1-CIDR
}

resource "azurerm_subnet" "data" {
  name                 = "data"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg_name
  address_prefixes     = var.subnet2-CIDR
}

resource "azurerm_subnet" "web" {
  name                 = "web"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg_name
  address_prefixes     = var.subnet3-CIDR
}

resource "azurerm_subnet" "gateway" {
  name                 = "gateway"
  virtual_network_name = azurerm_virtual_network.vnet.name
  resource_group_name  = var.rg_name
  address_prefixes     = var.subnet4-CIDR
}

resource "azurerm_public_ip" "publicIp" {
  name                         = "gatewayPublicIp"
  location                     = var.rg_location
  resource_group_name          = var.rg_name
  allocation_method            = "Static"
  sku                          = "Standard"
  tags                         = var.tags
}
