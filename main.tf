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
  features {}
}

# Hub Network Module
module "azure_networking_global" {
  source = "./azure-networking-global"

  name_prefix           = var.name_prefix
  location             = var.location
  hub_address_space    = var.hub_address_space
  enable_bastion       = var.enable_bastion
  enable_vpn_gateway   = var.enable_vpn_gateway
  tags                 = var.tags
}

# Spoke Network Module - COMMENTED OUT FOR STEP-BY-STEP DEPLOYMENT
# module "azure_core_infrastructure" {
#   source = "./azure-core-infrastructure"

#   name_prefix           = var.name_prefix
#   location             = var.location
#   spoke_address_space  = var.spoke_address_space
#   enable_hub_peering   = var.enable_hub_peering
#   hub_vnet_id          = module.azure_networking_global.hub_virtual_network.id
#   tags                 = var.tags

#   depends_on = [module.azure_networking_global]
# }

# Jenkins VM Module - COMMENTED OUT FOR STEP-BY-STEP DEPLOYMENT
# module "azure_jenkins_vm" {
#   source = "./azure-jenkins-vm"

#   name_prefix         = var.name_prefix
#   resource_group_name = module.azure_core_infrastructure.resource_group.name
#   vnet_name          = module.azure_core_infrastructure.spoke_virtual_network.name
#   ssh_public_key     = var.ssh_public_key
#   vm_size            = var.jenkins_vm_size
#   tags               = var.tags

#   depends_on = [module.azure_core_infrastructure]
# }

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