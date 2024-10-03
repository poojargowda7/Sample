/**********************************************************************
* Project                       	: Azure Landing Zone & IaC Templates
*
* Module Name                   	: Azure UBUNTU VM instance
*
* Author                        	: Rajesh Nandimandalam
*
* Date created                  	: 20210211
*
* Purpose                       	: Terraform module for creating UBUNTU VM instance
*
* Resources Implemented      		: Availability Set,Storage Account,Network Interface Card,Load Balancer,Backend Pool,LB Rule,LB Probe,LB Nat Rule,Network Interface BAP Association,Network Interface Nat rule Association, VM,VM Extension
*
* Datasource Resources				: Resource Group,Virtual Networks,Subnet
*
* Notes                         	: Implementation of Azure Landing Zone Resource's
*
* Revision History              	:
* Date        Author     Ref    Revision (Date in YYYYMMDD format)
*20210211	Akundi Rama			20210211
*
**********************************************************************/

provider "azurerm" {
  # Whilst version is optional, we /strongly recommend/ using it to pin the version of the Provider being used
  features {}
}

#
# - Create a Availability Set
#

resource "azurerm_availability_set" "availability_set" {
   name                          = "${var.prefix}-availability_set"
   location                      = data.azurerm_resource_group.rg.location
   resource_group_name           = data.azurerm_resource_group.rg.name
   managed                       = var.managed
   platform_fault_domain_count   = var.platform_fault_domain_count

}

#
# - Create a Storage account with Network Rules
#

resource "azurerm_storage_account" "sa" {
    name                          =    var.storage_account_name
    resource_group_name           =    data.azurerm_resource_group.rg.name
    location                      =    data.azurerm_resource_group.rg.location
    account_tier                  =    var.account_tier
    account_replication_type      =    var.account_replication_type
}


#
# - Public IP (To Login to Linux VM)
#

resource "azurerm_public_ip" "pip" {
    name                            =     "${var.prefix}-linuxvm-public-ip"
    resource_group_name             =     data.azurerm_resource_group.rg.name
    location                        =     data.azurerm_resource_group.rg.location
    allocation_method               =     var.allocation_method
    sku                             =     var.account_tier
}

#
# - Create a Load Balancer with Backend Pool
#

resource "azurerm_lb" "lb" {
 name                = "${var.prefix}-lb"
 location            = data.azurerm_resource_group.rg.location
 resource_group_name = data.azurerm_resource_group.rg.name
 sku                 = var.lb_sku
 frontend_ip_configuration {
   name                 = "PublicIPAddress"
   public_ip_address_id = azurerm_public_ip.pip.id
 }
}

resource "azurerm_lb_backend_address_pool" "lbap" {
  name                = "${var.prefix}-lbap"
  loadbalancer_id     = azurerm_lb.lb.id
}

resource "azurerm_lb_probe" "lbprobe" {

  name                = "${var.prefix}-lbprobe"
  resource_group_name = data.azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "TCP"
  port                = "80"
  interval_in_seconds = "5"
  number_of_probes    = "2"
}

resource "azurerm_lb_rule" "lbrulehttps" {
  name                           = "${var.prefix}-lbrulehttps"
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "TCP"
  frontend_port                  = "443"
  backend_port                   = "443"
  frontend_ip_configuration_name = "PublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lbap.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.lbprobe.id
  load_distribution              = "SourceIP"
}

resource "azurerm_lb_rule" "lbrulehttp" {
  name                           = "${var.prefix}-lbrulehttp"
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "TCP"
  frontend_port                  = "80"
  backend_port                   = "80"
  frontend_ip_configuration_name = "PublicIPAddress"
  enable_floating_ip             = false
  backend_address_pool_id        = azurerm_lb_backend_address_pool.lbap.id
  idle_timeout_in_minutes        = 5
  probe_id                       = azurerm_lb_probe.lbprobe.id
  load_distribution              = "SourceIP"
}

resource "azurerm_lb_nat_rule" "lbnatrule" {
  name                           = "${var.prefix}-lbnatrule"
  resource_group_name            = data.azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.lb.id
  protocol                       = "TCP"
  frontend_port                  = "22"
  backend_port                   = "22"
  frontend_ip_configuration_name = "PublicIPAddress"
}



#
# - Create a Network Interface Card for Virtual Machine
#

resource "azurerm_network_interface" "nic" {
    name                              =   "${var.prefix}-linuxvm-nic"
    resource_group_name               =   data.azurerm_resource_group.rg.name
    location                          =   data.azurerm_resource_group.rg.location
    ip_configuration                  {
        name                          =  "${var.prefix}-nic-ipconfig"
        subnet_id                     =   data.azurerm_subnet.sn.id
        private_ip_address_allocation =   var.allocation_methods
    }
}


resource "azurerm_network_interface_backend_address_pool_association" "bapa" {
  network_interface_id    =  azurerm_network_interface.nic.id
  ip_configuration_name   = "${var.prefix}-nic-ipconfig"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lbap.id
}


resource "azurerm_network_interface_nat_rule_association" "natruleassociation" {
  network_interface_id    =  azurerm_network_interface.nic.id
  ip_configuration_name = "${var.prefix}-nic-ipconfig"
  nat_rule_id           = azurerm_lb_nat_rule.lbnatrule.id
}

#
# - Create a Linux Virtual Machine
# 

resource "azurerm_linux_virtual_machine" "vm" {
    name                              =   "${var.prefix}-linuxvm"
    resource_group_name               =   data.azurerm_resource_group.rg.name
    location                          =   data.azurerm_resource_group.rg.location
    availability_set_id               =   azurerm_availability_set.availability_set.id
    network_interface_ids             =   [azurerm_network_interface.nic.id]
    size                              =   var.virtual_machine_size
    computer_name                     =   var.computer_name
    admin_username                    =   var.admin_username
    admin_password                    =   var.admin_password
    disable_password_authentication   =   false

    os_disk  {
        name                          =   "${var.prefix}-linuxvm-os-disk"
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
}

resource "azurerm_virtual_machine_extension" "vmext" {
  name                               =   "LinuxVM-RunScripts"
  virtual_machine_id                 =   azurerm_linux_virtual_machine.vm.id
  publisher                          =   "Microsoft.Azure.Extensions"
  type                               =   "CustomScript"
  type_handler_version               =   "2.0"

  settings = <<SETTINGS
    {
        "script": "${filebase64("../.modules/morpheus-core/cmp_morpheus_ansible.sh")}"
    }
SETTINGS

}
