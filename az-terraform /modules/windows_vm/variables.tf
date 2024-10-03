#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*
# Windows 10 VM - Variables
#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*#*

# Prefix and Tags

variable "prefix" {
    description =   "Prefix to append to all resource names"
    type        =   string
    default     =   ""
}

variable "tags" {
    description =   "Resouce tags"
    type        =   map(string)
    default     =   {
        "project"       =   "stealth"
        "deployed_with" =   "cmp"
    }
}

# Resource Group

variable "location" {
    description =   "Location of the resource group"
    type        =   string
    default     =   "East US"
}

# Vnet and Subnet

variable "vnet_address_range" {
    description =   "IP Range of the virtual network"
    type        =   string
    default     =   "10.10.0.0/16"
}

variable "subnet_address_range" {
    description =   "IP Range of the virtual network"
    type        =   string
    default     =   "10.10.0.0/24"
}

# Public IP and NIC Allocation Method

variable "allocation_method" {
    description =   "Allocation method for Public IP Address and NIC Private ip address"
    type        =   list(string)
    default     =   ["Static", "Dynamic"]
}


# VM 

variable "virtual_machine_size" {
    description =   "Size of the VM"
    type        =   string
    default     =   "Standard_B4ms"
}

variable "computer_name" {
    description =   "Computer name"
    type        =   string
    default     =   "win10stealth"
}

variable "admin_username" {
    description =   "Username to login to the VM"
    type        =   string
    default     =   ""
}

variable "admin_password" {
    description =   "Password to login to the VM"
    type        =   string
    default     =   ""
}

variable "os_disk_caching" {
    default     =       "ReadWrite"
}

variable "os_disk_storage_account_type" {
    default     =       "StandardSSD_LRS"
}

variable "os_disk_size_gb" {
    default     =       130
}

variable "publisher" {
    default         =       "MicrosoftWindowsDesktop"
}

variable "offer" {
    default         =       "Windows-10"
}

variable "sku" {
    default         =       "rs5-pro"
}

variable "vm_image_version" {
    default         =       "latest"
}


variable "managed" {
    description =   "AS managed value"
    type        =   string
}

variable "platform_fault_domain_count" {
    description =   "AS fault domain count"
    type        =   string
}

/*
variable "storage_account_name" {
    description =   "Storage account name"
    type        =   string
}

variable "account_tier" {
    description =   "Storage account type"
    type        =   string
}

variable "account_replication_type" {
    description =   "Storage account replication type"
    type        =   string
}
*/
