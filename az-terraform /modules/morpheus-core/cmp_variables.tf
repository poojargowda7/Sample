#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Linux VM - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

# Prefix and Tags

variable "prefix" {
    description =   "Prefix to append to all resource names"
    type        =   string
    default     =   "CMP35"
}

variable "existing_rg_name" {
    description =   "Name of resource group"
    type        =   string
	default     =   "CMP-USEAST-RG"
}

variable "existing_vnet_name" {
    description =   "Name of vnet"
    type        =   string
	default     =   "CF-CMP-Mor-Dev-vnet"
}

variable "lb_sku" {
    description = "Load balancer of the SKU"
    type        =   string
    default     = "Standard"
}

# Public IP and NIC Allocation Method

variable "allocation_method" {
    description =   "Allocation method for Public IP Address and NIC Private ip address"
    type        =   string
    default     =   "Static"
}

# Availability Set

variable "managed" {
    type    =   string
    default =   true
}

variable "platform_fault_domain_count" {
    type    =   string
    default =   2
}


variable "allocation_methods" {
    description =   "Allocation method for Public IP Address and NIC Private ip address"
    type        =   string
    default     =   "Dynamic"
}

# Storage 

variable "storage_account_name" {
    description = "Variables for Storage account name(Storage account name should be unique(Eg:saopsdf2)"
    default     = "cmp25sarmadryrun2"
}

variable "account_tier" {
    description  =  "Variables for Storage accounts and containers"
    type         =  string
    default      =  "Standard"
       
}
    
variable "account_replication_type" {
    description  =  "Variables for Storage accounts and containers"
    type         =  string
    default      =  "LRS"
      
}

# VM 

variable "virtual_machine_size" {
    description =   "Size of the VM"
    type        =   string
    default     =   "Standard_D4s_v3"
}

variable "computer_name" {
    description =   "Computer name"
    type        =   string
    default     =   "Linuxvm"
}

variable "admin_username" {
    description =   "Username to login to the VM"
    type        =   string
    default     =   "cmpadmin"
}

variable "admin_password" {
    description =   "Password to login to the VM"
    type        =   string
    default     =   "Unisys*12345"
}

variable "os_disk_caching" {
    default     =       "ReadWrite"
}

variable "os_disk_storage_account_type" {
    default     =       "StandardSSD_LRS"
}

variable "os_disk_size_gb" {
    default     =       64
}

variable "publisher" {
    default     =       "Canonical"
}

variable "offer" {
    default     =       "UbuntuServer"
}

variable "sku" {
    default     =       "18.04-LTS"
}

variable "vm_image_version" {
    default     =       "latest"
}

variable "subscription_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
	default		 =  "528db867-aafd-4420-b517-2e2863ca7305"	
}

variable "client_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
	default		 =  "f7a4ff5e-d0f0-4226-bec9-c3e8e9e88083"
}

variable "client_secret"  {
    description  =  "Variables for Storage accounts"
    type         =  string
	default		 =  "OIQIrf7J0.998QwS02_RVyuF2la_g_.q5G"
}
variable "tenant_id"  {
    description  =  "Variables for Storage accounts"
    type         =  string
	default		 =  "8d894c2b-238f-490b-8dd1-d93898c5bf83"
}