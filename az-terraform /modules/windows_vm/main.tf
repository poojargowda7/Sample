#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Create a Windows VM 
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

#
# - Create a Resource Group
#

resource "azurerm_resource_group" "rg" {
    name                  =   "${var.prefix}-rg"
    location              =   var.location
    tags                  =   var.tags
}

resource "azurerm_availability_set" "availability_set" {
   name                          = "${var.prefix}-availability_set"
   location                      = azurerm_resource_group.rg.location
   resource_group_name           = azurerm_resource_group.rg.name
   managed                       = var.managed
   platform_fault_domain_count   = var.platform_fault_domain_count

}


#
# - Create a Virtual Network
#

resource "azurerm_virtual_network" "vnet" {
    name                  =   "${var.prefix}-vnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    location              =   azurerm_resource_group.rg.location
    address_space         =   [var.vnet_address_range]
    tags                  =   var.tags
}

#
# - Create a Subnet inside the virtual network
#

resource "azurerm_subnet" "web" {
    name                  =   "${var.prefix}-web-subnet"
    resource_group_name   =   azurerm_resource_group.rg.name
    virtual_network_name  =   azurerm_virtual_network.vnet.name
    address_prefixes      =   [var.subnet_address_range]
}

#
# - Create a Network Security Group
#

resource "azurerm_network_security_group" "nsg" {
    name                        =       "${var.prefix}-web-nsg"
    resource_group_name         =       azurerm_resource_group.rg.name
    location                    =       azurerm_resource_group.rg.location
    tags                        =       var.tags

    security_rule {
    name                        =       "Allow_RDP"
    priority                    =       1000
    direction                   =       "Inbound"
    access                      =       "Allow"
    protocol                    =       "Tcp"
    source_port_range           =       "*"
    destination_port_range      =       3389
    source_address_prefix       =       "*" 
    destination_address_prefix  =       "*"
    
    }
}


#
# - Subnet-NSG Association
#

resource "azurerm_subnet_network_security_group_association" "subnet-nsg" {
    subnet_id                    =       azurerm_subnet.web.id
    network_security_group_id    =       azurerm_network_security_group.nsg.id
}


#
# - Storage Account (Blob)
#
/*
resource "azurerm_storage_account" "sa" {
    name                          =    var.storage_account_name
    resource_group_name           =    azurerm_resource_group.rg.name
    location                      =    azurerm_resource_group.rg.location
  #   account_kind				          =    "StorageV2"
    account_tier                  =    var.account_tier
  #  enable_https_traffic_only     =    false
    account_replication_type      =    var.account_replication_type
}
*/
#
# - Create a Network Interface Card for Virtual Machine
#

resource "azurerm_network_interface" "nic" {
    name                              =   "${var.prefix}-winvm-nic-${count.index + 1}"
    resource_group_name               =   azurerm_resource_group.rg.name
    location                          =   azurerm_resource_group.rg.location
    count                             =   "2"
    tags                              =   var.tags
    ip_configuration                  {
        name                          =  "${var.prefix}-nic-ipconfig"
        subnet_id                     =   azurerm_subnet.web.id
        private_ip_address_allocation =   var.allocation_method[1]
    }
}


#
# - Create a Windows 10 Virtual Machine
#

resource "azurerm_windows_virtual_machine" "vm" {
    name                              =   "${var.prefix}-winvm-${count.index + 1}"
    resource_group_name               =   azurerm_resource_group.rg.name
    location                          =   azurerm_resource_group.rg.location
    #network_interface_ids             =   [azurerm_network_interface.nic.id]
    network_interface_ids              =  ["${element(azurerm_network_interface.nic.*.id, count.index)}"]
    size                              =   var.virtual_machine_size
    computer_name                     =   "${var.computer_name}-${count.index + 1}"
    admin_username                    =   var.admin_username
    admin_password                    =   var.admin_password
    count                             =   "2"

    os_disk  {
        name                          =   "${var.prefix}-winvm-os-disk-${count.index + 1}"
        caching                       =   var.os_disk_caching
        storage_account_type          =   var.os_disk_storage_account_type
        disk_size_gb                  =   var.os_disk_size_gb
    }

    source_image_reference {
        publisher                     =   var.publisher
        offer                         =   var.offer
        sku                           =   var.sku
        version                       =   var.vm_image_version
    }

    tags                              =   var.tags

}
