# Azure Firezone Gateway Variables
# Equivalent to GCP terraform-google-gateway variables

variable "name_prefix" {
  type        = string
  default     = ""
  description = "Prefix for all resource names"
}

variable "location" {
  type        = string
  description = "Azure region where resources will be created"
}

variable "availability_zones" {
  type        = list(string)
  default     = []
  description = "List of availability zones. Empty list means all available zones will be used."
}

################################################################################
## Networking
################################################################################

variable "subnet_id" {
  type        = string
  description = "ID of the subnet where VMs will be deployed"
}

variable "gateway_subnet_id" {
  type        = string
  default     = null
  description = "ID of the subnet for Application Gateway (required if enable_load_balancer is true)"
}

variable "enable_public_ip" {
  type        = bool
  default     = true
  description = "Whether to assign public IP addresses to VM instances"
}

variable "enable_load_balancer" {
  type        = bool
  default     = false
  description = "Whether to create an Application Gateway for load balancing"
}

################################################################################
## Virtual Machine Scale Set
################################################################################

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
  description = "Size of the virtual machines in the scale set"
}

variable "instance_count" {
  type        = number
  default     = 1
  description = "Number of VM instances in the scale set"
}

variable "os_disk_type" {
  type        = string
  default     = "Premium_LRS"
  description = "Type of OS disk (Premium_LRS, Standard_LRS, StandardSSD_LRS)"
  
  validation {
    condition     = contains(["Premium_LRS", "Standard_LRS", "StandardSSD_LRS"], var.os_disk_type)
    error_message = "OS disk type must be Premium_LRS, Standard_LRS, or StandardSSD_LRS."
  }
}

variable "admin_username" {
  type        = string
  default     = "azureuser"
  description = "Admin username for the VMs"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM access"
}

variable "swap_size_gb" {
  type        = number
  default     = 0
  description = "Size of the swap partition in GB. Default is 0, or disabled."
}

################################################################################
## Firezone Configuration
################################################################################

variable "firezone_token" {
  type        = string
  description = "Portal token to use for authentication"
  sensitive   = true
}

variable "firezone_api_url" {
  type        = string
  default     = "wss://api.firezone.dev"
  description = "URL of the control plane endpoint"
}

variable "firezone_artifact_url" {
  type        = string
  default     = "https://www.firezone.dev/dl/firezone-gateway"
  description = "URL from which Firezone install script will download the gateway binary"
}

variable "firezone_version" {
  type        = string
  default     = "latest"
  description = "Version of the Firezone gateway"
}

################################################################################
## Observability
################################################################################

variable "log_level" {
  type        = string
  default     = "info"
  description = "Log level for Firezone gateway (debug, info, warn, error)"
  
  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "Log level must be one of: debug, info, warn, error."
  }
}

variable "log_format" {
  type        = string
  default     = "human"
  description = "Log format (human or json)"
  
  validation {
    condition     = contains(["human", "json"], var.log_format)
    error_message = "Log format must be either 'human' or 'json'."
  }
}

################################################################################
## Health Check
################################################################################

variable "health_check" {
  type = object({
    port                = number
    path                = string
    interval_seconds    = number
    timeout_seconds     = number
    unhealthy_threshold = number
  })
  
  default = {
    port                = 8080
    path                = "/healthz"
    interval_seconds    = 15
    timeout_seconds     = 10
    unhealthy_threshold = 3
  }
  
  description = "Health check configuration for the load balancer"
}

################################################################################
## Tags
################################################################################

variable "tags" {
  type        = map(string)
  default     = {}
  description = "Tags to apply to all resources"
}