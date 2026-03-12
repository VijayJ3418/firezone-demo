# Azure Jenkins Infrastructure - Root Variables

variable "name_prefix" {
  type        = string
  default     = "vijay-"
  description = "Prefix for all resource names"
}

variable "location" {
  type        = string
  default     = "Central US"
  description = "Azure region for deployment (Central US often has better free trial availability)"
}

variable "hub_address_space" {
  type        = string
  default     = "172.16.0.0/16"
  description = "Address space for the hub virtual network"
}

variable "hub_vpn_subnet_cidr" {
  type        = string
  default     = "172.16.0.0/24"
  description = "CIDR block for VPN subnet in hub network"
}

variable "spoke_address_space" {
  type        = string
  default     = "192.168.0.0/16"
  description = "Address space for the spoke virtual network"
}

variable "enable_bastion" {
  type        = bool
  default     = false
  description = "Whether to create Azure Bastion for secure access"
}

variable "enable_vpn_gateway" {
  type        = bool
  default     = false
  description = "Whether to create VPN Gateway (disabled to avoid provider issues)"
}

variable "enable_hub_peering" {
  type        = bool
  default     = true
  description = "Whether to create VNet peering between hub and spoke"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM access"
}

variable "jenkins_vm_size" {
  type        = string
  default     = "Standard_DS1_v2"
  description = "Size of the Jenkins VM (DS1_v2 often more available than F1s in free trials)"
}

variable "jenkins_static_ip" {
  type        = string
  default     = "192.168.129.50"
  description = "Static private IP for Application Gateway"
}

variable "secondary_region" {
  type        = string
  default     = "West US 2"
  description = "Secondary Azure region for multi-region deployment"
}

variable "secondary_spoke_address_space" {
  type        = string
  default     = "10.168.0.0/16"
  description = "Address space for the secondary spoke virtual network"
}

variable "vpn_subnet_cidr" {
  type        = string
  default     = "192.168.131.0/24"
  description = "CIDR block for VPN subnet in primary region"
}

variable "secondary_vpn_subnet_cidr" {
  type        = string
  default     = "10.168.130.0/24"
  description = "CIDR block for VPN subnet in secondary region"
}

variable "jenkins_fqdn" {
  type        = string
  default     = "jenkins.np.dglearn.online"
  description = "FQDN for Jenkins"
}

variable "firezone_token" {
  type        = string
  default     = ""
  description = "Firezone authentication token for gateway registration"
  sensitive   = true
}

variable "enable_firezone_multi_region" {
  type        = bool
  default     = false
  description = "Whether to enable multi-region Firezone deployment with load balancer"
}

variable "tags" {
  type        = map(string)
  default     = {
    Environment = "demo"
    Project     = "jenkins"
    ManagedBy   = "terraform"
  }
  description = "Tags to apply to all resources"
}

# Additional variables needed by modules
variable "jenkins_subnet_cidr" {
  type        = string
  default     = "192.168.0.0/24"
  description = "CIDR block for Jenkins subnet"
}

variable "appgw_subnet_cidr" {
  type        = string
  default     = "192.168.128.0/23"
  description = "CIDR block for Application Gateway subnet"
}

variable "gateway_subnet_cidr" {
  type        = string
  default     = "172.16.1.0/24"
  description = "CIDR block for VPN Gateway subnet in hub network"
}

variable "bastion_subnet_cidr" {
  type        = string
  default     = "172.16.2.0/24"
  description = "CIDR block for Azure Bastion subnet"
}

variable "vpn_gateway_sku" {
  type        = string
  default     = "VpnGw1"
  description = "SKU for VPN Gateway"
}

variable "dns_zone_name" {
  type        = string
  default     = "dglearn.online"
  description = "Name of the private DNS zone"
}