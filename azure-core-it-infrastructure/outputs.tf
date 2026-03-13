# Outputs for Azure Core IT Infrastructure Module

output "resource_group" {
  description = "Core IT Infrastructure resource group"
  value = {
    id       = azurerm_resource_group.core_it_rg.id
    name     = azurerm_resource_group.core_it_rg.name
    location = azurerm_resource_group.core_it_rg.location
  }
}

output "core_it_virtual_network" {
  description = "Core IT Infrastructure virtual network"
  value = {
    id            = azurerm_virtual_network.core_it_vnet.id
    name          = azurerm_virtual_network.core_it_vnet.name
    address_space = azurerm_virtual_network.core_it_vnet.address_space
  }
}

output "jenkins_subnet" {
  description = "Jenkins subnet information"
  value = {
    id               = azurerm_subnet.jenkins_subnet.id
    name             = azurerm_subnet.jenkins_subnet.name
    address_prefixes = azurerm_subnet.jenkins_subnet.address_prefixes
  }
}

output "appgw_subnet" {
  description = "Application Gateway subnet information"
  value = {
    id               = azurerm_subnet.appgw_subnet.id
    name             = azurerm_subnet.appgw_subnet.name
    address_prefixes = azurerm_subnet.appgw_subnet.address_prefixes
  }
}

output "jenkins_nsg" {
  description = "Jenkins network security group"
  value = {
    id   = azurerm_network_security_group.jenkins_nsg.id
    name = azurerm_network_security_group.jenkins_nsg.name
  }
}

output "appgw_nsg" {
  description = "Application Gateway network security group"
  value = {
    id   = azurerm_network_security_group.appgw_nsg.id
    name = azurerm_network_security_group.appgw_nsg.name
  }
}

output "dns_zone" {
  description = "Private DNS zone information"
  value = var.dns_zone_name != "" ? {
    id   = azurerm_private_dns_zone.core_it_dns[0].id
    name = azurerm_private_dns_zone.core_it_dns[0].name
  } : null
}

output "vnet_peering" {
  description = "VNet peering information"
  value = var.enable_hub_peering ? {
    core_it_to_hub = azurerm_virtual_network_peering.core_it_to_hub[0].id
    hub_to_core_it = azurerm_virtual_network_peering.hub_to_core_it[0].id
  } : null
}