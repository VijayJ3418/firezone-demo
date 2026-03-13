# Outputs for Azure Networking Global (Hub)

output "resource_group" {
  description = "Hub network resource group information"
  value = {
    name     = azurerm_resource_group.networking_global.name
    location = azurerm_resource_group.networking_global.location
    id       = azurerm_resource_group.networking_global.id
  }
}

output "hub_virtual_network" {
  description = "Hub virtual network information"
  value = {
    name          = azurerm_virtual_network.vpc_hub.name
    id            = azurerm_virtual_network.vpc_hub.id
    address_space = azurerm_virtual_network.vpc_hub.address_space
  }
}

output "vpn_subnet" {
  description = "VPN subnet information"
  value = {
    name             = azurerm_subnet.subnet_vpn.name
    id               = azurerm_subnet.subnet_vpn.id
    address_prefixes = azurerm_subnet.subnet_vpn.address_prefixes
  }
}

output "firezone_subnet" {
  description = "Firezone subnet information"
  value = {
    name             = azurerm_subnet.firezone_subnet.name
    id               = azurerm_subnet.firezone_subnet.id
    address_prefixes = azurerm_subnet.firezone_subnet.address_prefixes
  }
}

output "gateway_subnet" {
  description = "Gateway subnet information (if VPN gateway enabled)"
  value = var.enable_vpn_gateway ? {
    name             = azurerm_subnet.gateway_subnet[0].name
    id               = azurerm_subnet.gateway_subnet[0].id
    address_prefixes = azurerm_subnet.gateway_subnet[0].address_prefixes
  } : null
}

output "network_security_group" {
  description = "Hub network security group information"
  value = {
    name = azurerm_network_security_group.hub_nsg.name
    id   = azurerm_network_security_group.hub_nsg.id
  }
}

output "vpn_gateway" {
  description = "VPN Gateway information (if enabled)"
  value = var.enable_vpn_gateway ? {
    name      = azurerm_virtual_network_gateway.vpn_gateway[0].name
    id        = azurerm_virtual_network_gateway.vpn_gateway[0].id
    public_ip = azurerm_public_ip.vpn_gateway_pip[0].ip_address
  } : null
}

output "bastion_host" {
  description = "Azure Bastion information (if enabled)"
  value = var.enable_bastion ? {
    name      = azurerm_bastion_host.bastion[0].name
    id        = azurerm_bastion_host.bastion[0].id
    public_ip = azurerm_public_ip.bastion_pip[0].ip_address
    fqdn      = azurerm_public_ip.bastion_pip[0].fqdn
  } : null
}

output "peering_info" {
  description = "Information needed for VNet peering"
  value = {
    hub_vnet_id           = azurerm_virtual_network.vpc_hub.id
    hub_vnet_name         = azurerm_virtual_network.vpc_hub.name
    hub_resource_group    = azurerm_resource_group.networking_global.name
    hub_address_space     = var.hub_address_space
  }
}