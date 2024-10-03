output "azurerm_subnet_app_id" {
  value = azurerm_subnet.app.id
}
output "azurerm_subnet_data_id" {
  value = azurerm_subnet.data.id
}
output "azurerm_subnet_web_id" {
  value = azurerm_subnet.web.id
}
output "azurerm_vnet_name" {
  value = azurerm_virtual_network.vnet.name
}
output "azurerm_subnet_gateway_id" {
  value = azurerm_subnet.gateway.id
}
output "azurerm_public_ip_id" {
  value = azurerm_public_ip.publicIp.id
}
