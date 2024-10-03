#provide organisation,project,creator user email id values

variable "tags" {
  type = map(string)

  default = {
    source = "terraform"
    organization = "unisys"
    project = "cf-containers"
    creator = "admin@unisys.com"
  }
}


variable "prefix" {
  description = "A prefix used for all resources in this AKS"
}

variable "rg_name" {
  description = "Resource group name"
}

variable "location" {
  description = "The Azure Region in which all resources in this AKS should be provisioned[needs zone support]: eastus2, eastus, centralus"
  default = "westus2"
}

variable "aad_admin_group_id" {
  description = "AAD admin group which will be added as admin privileged user for AKS"
}

variable "aad_tenant_id" {
  description = "Tenant ID of AAD owner cloud account"
}

variable "aks_vmss_sku" {
  description = "SKU for AKS Virtual Machine Scale Sets. Default is 'Standard_DS2_v2'."
  default     = "Standard_DS2_v2"
}

variable "kubernetes_version" {
  description = "kubernetes version"
  default     = "1.20.7"
}

variable "network_policy" {
  description = "Enter 0 or 1 as per the choice:- [ 0 for Azure Network Policy, 1 for Calico Network Policy]"
  default    = "1"
}

variable "azure_policy" {
  description = "Enter 0 or 1 as per the choice:- [ 0 for Azure Policy, 1 for OPA Gatekeeper Policy]"
  default    = "1"
}

variable "vnet_CIDR" {
  description = "Enter CIDR for VNET"
  default = ["10.22.0.0/16"]
}

variable "subnet1-CIDR" {
  description = "Enter subnet1 CIDR"
  default = ["10.22.0.0/22"]
}

variable "subnet2-CIDR" {
  description = "Enter subnet2 CIDR"
  default = ["10.22.4.0/22"]
}

variable "subnet3-CIDR" {
  description = "Enter subnet3 CIDR"
  default = ["10.22.8.0/22"]
}

variable "subnet4-CIDR" {
  description = "Enter subnet4 CIDR"
  default = ["10.22.12.0/22"]
}

variable "app_node_count" {
  description = "No. of node for default node pool of AKS"
  default = 1
}

variable "app_max_count" {
  description = "Maximum number of node for default node pool of AKS"
  default = 2
}

variable "app_min_count" {
  description = "Minimum number of node for default node pool of AKS"
  default = 1
}

variable "app_max_pods" {
  description = "Maximum number of pods for default node pool of AKS"
  default = 75
}

variable "app_availability_zones" {
  description = "Availability zone for default node pool of AKS"
  default = [ "1", "2", "3" ]
}

variable "data_node_count" {
  description = "No. of node for data node pool of AKS"
  default = 1
}

variable "data_max_count" {
  description = "Maximum number of node for data node pool of AKS"
  default = 2
}

variable "data_min_count" {
  description = "Minimum number of node for data node pool of AKS"
  default = 1
}

variable "data_max_pods" {
  description = "Maximum number of pods for data node pool of AKS"
  default = 75
}

variable "data_availability_zones" {
  description = "Availability zone for data node pool of AKS"
  default = [ "1", "2", "3" ]
}

variable "web_node_count" {
  description = "No. of node for web node pool of AKS"
  default = 1
}

variable "web_max_count" {
  description = "Maximum number of node for web node pool of AKS"
  default = 2
}

variable "web_min_count" {
  description = "Minimum number of node for web node pool of AKS"
  default = 1
}

variable "web_max_pods" {
  description = "Maximum number of pods for web node pool of AKS"
  default = 75
}

variable "web_availability_zones" {
  description = "Availability zone for web node pool of AKS"
  default = [ "1", "2", "3" ]
}
