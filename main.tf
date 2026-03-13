# Azure Jenkins Infrastructure - Root Configuration
# This is the main entry point for deploying the complete Azure infrastructure

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Hub Network Module - ENABLED FOR ORIGINAL EXERCISE REQUIREMENTS
module "azure_networking_global" {
  source = "./azure-networking-global"

  name_prefix            = var.name_prefix
  location              = var.location
  hub_address_space     = var.hub_address_space
  vpn_subnet_cidr       = var.hub_vpn_subnet_cidr
  gateway_subnet_cidr   = var.gateway_subnet_cidr
  bastion_subnet_cidr   = var.bastion_subnet_cidr
  spoke_address_spaces  = [var.spoke_address_space, var.secondary_spoke_address_space]
  enable_bastion        = var.enable_bastion
  enable_vpn_gateway    = var.enable_vpn_gateway
  vpn_gateway_sku       = var.vpn_gateway_sku
  tags                  = var.tags
}

# Spoke Network Module - WITH HUB PEERING AS PER EXERCISE REQUIREMENTS
module "azure_core_infrastructure" {
  source = "./azure-core-infrastructure"

  name_prefix              = var.name_prefix
  location                = var.location
  spoke_address_space     = var.spoke_address_space
  jenkins_subnet_cidr     = var.jenkins_subnet_cidr
  appgw_subnet_cidr       = var.appgw_subnet_cidr
  vpn_subnet_cidr         = var.vpn_subnet_cidr
  hub_address_space       = var.hub_address_space
  enable_hub_peering      = var.enable_hub_peering
  hub_vnet_id             = module.azure_networking_global.hub_virtual_network.id
  hub_resource_group_name = module.azure_networking_global.resource_group.name
  hub_vnet_name           = module.azure_networking_global.hub_virtual_network.name
  hub_has_gateway         = var.enable_vpn_gateway
  use_remote_gateways     = false
  dns_zone_name           = var.dns_zone_name
  tags                    = var.tags

  depends_on = [module.azure_networking_global]
}

# Jenkins VM Module - ENABLED WITH FREE TRIAL COMPATIBLE VM SIZE
module "azure_jenkins_vm" {
  source = "./azure-jenkins-vm"

  name_prefix         = var.name_prefix
  resource_group_name = module.azure_core_infrastructure.resource_group.name
  vnet_name          = module.azure_core_infrastructure.spoke_virtual_network.name
  ssh_public_key     = var.ssh_public_key
  vm_size            = var.jenkins_vm_size
  tags               = var.tags

  depends_on = [module.azure_core_infrastructure]
}

# Secondary Region Infrastructure for Firezone - DISABLED (using same region for Load Balancer)
# module "azure_core_infrastructure_secondary" {
#   count  = false ? 1 : 0  # Disabled - both gateways deploy in same region
#   source = "./azure-core-infrastructure-secondary"

#   name_prefix                  = var.name_prefix
#   location                    = var.secondary_region
#   spoke_address_space         = var.secondary_spoke_address_space
#   vpn_subnet_cidr             = var.secondary_vpn_subnet_cidr
#   enable_primary_peering      = true
#   primary_vnet_id             = module.azure_core_infrastructure.spoke_virtual_network.id
#   primary_resource_group_name = module.azure_core_infrastructure.resource_group.name
#   primary_vnet_name           = module.azure_core_infrastructure.spoke_virtual_network.name
#   tags                        = var.tags

#   depends_on = [module.azure_core_infrastructure]
# }

# Multi-Region Firezone VPN Gateway Deployment - ENABLED
module "azure_firezone_multi_region" {
  count  = var.enable_firezone_multi_region ? 1 : 0
  source = "./azure-firezone-multi-region"

  name_prefix                     = var.name_prefix
  primary_region                  = var.location
  primary_resource_group_name     = module.azure_core_infrastructure.resource_group.name
  primary_vnet_name              = module.azure_core_infrastructure.spoke_virtual_network.name
  primary_vnet_id                = module.azure_core_infrastructure.spoke_virtual_network.id
  primary_subnet_name            = module.azure_core_infrastructure.vpn_subnet.name
  secondary_region               = var.location  # Same region for Load Balancer compatibility
  secondary_resource_group_name  = module.azure_core_infrastructure.resource_group.name  # Same RG
  secondary_vnet_name           = module.azure_core_infrastructure.spoke_virtual_network.name  # Same VNet
  secondary_vnet_id             = module.azure_core_infrastructure.spoke_virtual_network.id  # Same VNet
  secondary_subnet_name         = module.azure_core_infrastructure.vpn_subnet.name  # Same subnet
  vm_size                       = "Standard_D2s_v3"
  ssh_public_key                = var.ssh_public_key
  firezone_token                = var.firezone_token
  log_level                     = var.firezone_log_level
  tags                          = var.tags

  depends_on = [
    module.azure_core_infrastructure
  ]
}

# Application Gateway Module - COMMENTED OUT FOR STEP-BY-STEP DEPLOYMENT
# module "azure_jenkins_appgw" {
#   source = "./azure-jenkins-appgw"

#   name_prefix         = var.name_prefix
#   resource_group_name = module.azure_core_infrastructure.resource_group.name
#   vnet_name          = module.azure_core_infrastructure.spoke_virtual_network.name
#   jenkins_private_ip = module.azure_jenkins_vm.jenkins_vm.private_ip_address
#   static_private_ip  = var.jenkins_static_ip
#   jenkins_fqdn       = var.jenkins_fqdn
#   tags               = var.tags

#   depends_on = [module.azure_jenkins_vm]
# }