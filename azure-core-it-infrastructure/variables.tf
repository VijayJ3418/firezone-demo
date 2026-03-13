# Variables for Azure Core IT Infrastructure Module

variable "name_prefix" {
  type        = string
  default     = ""
  description = "Prefix for all resource names"
}

variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region for deployment"
}

# Network Configuration
variable "core_it_address_space" {
  type        = string
  default     = "10.0.0.0/16"
  description = "Address space for Core IT Infrastructure VNet"
}

variable "jenkins_subnet_cidr" {
  type        = string
  default     = "10.0.1.0/24"
  description = "CIDR block for Jenkins subnet"
}

variable "appgw_subnet_cidr" {
  type        = string
  default     = "10.0.2.0/24"
  description = "CIDR block for Application Gateway subnet"
}

# Hub Network Integration
variable "enable_hub_peering" {
  type        = bool
  default     = true
  description = "Enable VNet peering with hub network"
}

variable "hub_vnet_id" {
  type        = string
  default     = ""
  description = "Hub virtual network ID for peering"
}

variable "hub_resource_group_name" {
  type        = string
  default     = ""
  description = "Hub resource group name"
}

variable "hub_vnet_name" {
  type        = string
  default     = ""
  description = "Hub virtual network name"
}

variable "hub_has_gateway" {
  type        = bool
  default     = false
  description = "Whether hub network has VPN gateway"
}

variable "use_remote_gateways" {
  type        = bool
  default     = false
  description = "Use remote gateways for connectivity"
}

variable "hub_firezone_subnet_cidr" {
  type        = string
  default     = "172.16.3.0/24"
  description = "CIDR block for Firezone subnet in hub network"
}

# DNS Configuration
variable "dns_zone_name" {
  type        = string
  default     = ""
  description = "Private DNS zone name (optional)"
}

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}