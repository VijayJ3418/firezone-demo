# Azure Jenkins Infrastructure - Root Variables

variable "name_prefix" {
  type        = string
  default     = "vijay-"
  description = "Prefix for all resource names"
}

variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region for deployment"
}

variable "hub_address_space" {
  type        = string
  default     = "172.16.0.0/16"
  description = "Address space for the hub virtual network"
}

variable "spoke_address_space" {
  type        = string
  default     = "192.168.0.0/16"
  description = "Address space for the spoke virtual network"
}

variable "enable_bastion" {
  type        = bool
  default     = true
  description = "Whether to create Azure Bastion for secure access"
}

variable "enable_vpn_gateway" {
  type        = bool
  default     = false
  description = "Whether to create VPN Gateway"
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
  default     = "Standard_D2s_v3"
  description = "Size of the Jenkins VM"
}

variable "jenkins_static_ip" {
  type        = string
  default     = "192.168.129.50"
  description = "Static private IP for Application Gateway"
}

variable "jenkins_fqdn" {
  type        = string
  default     = "jenkins.np.dglearn.online"
  description = "FQDN for Jenkins"
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