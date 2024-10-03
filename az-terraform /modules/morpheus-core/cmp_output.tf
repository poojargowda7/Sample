#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Linux VM - Outputs
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

output "resource-group-name" {
    description     =   "Print the name of the resource group"
    value           =   data.azurerm_resource_group.rg.name
}

output "resource-group-location" {
    description     =   "Print the location of the resource group"
    value           =   data.azurerm_resource_group.rg.location
}

output "virtual-network-name" {
    description     =   "Print the name of the virtual network"
    value           =   data.azurerm_virtual_network.vnet.name
}

output "virtual-network-ip-range" {
    description     =   "Print the ip range of the virtual network"
    value           =   data.azurerm_virtual_network.vnet.address_space
}

output "subnet-name" {
    description     =   "Print the name of the subnet"
    value           =   data.azurerm_subnet.sn.name
}

output "subnet-ip-range" {
    description     =   "Print the ip range of the subnet"
    value           =   [data.azurerm_subnet.sn.address_prefixes]
}


output "linux_nic_name" {
    value           =   azurerm_network_interface.nic.private_ip_address
}

output "public_ip_address" {
    value           =   azurerm_public_ip.pip.ip_address
}