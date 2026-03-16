# Azure Core Infrastructure (Spoke) - Equivalent to GCP core-it-infrastructure
# Creates the spoke network infrastructure for Azure

# Data sources
data "azurerm_client_config" "current" {}

# Resource Group for Core Infrastructure
resource "azurerm_resource_group" "core_infrastructure" {
  name     = "${var.name_prefix}core-infrastructure-rg"
  location = var.location
  tags     = var.tags
}

# Spoke Virtual Network (equivalent to vpc-spoke)
resource "azurerm_virtual_network" "vpc_spoke" {
  name                = "${var.name_prefix}vpc-spoke"
  address_space       = [var.spoke_address_space]
  location            = azurerm_resource_group.core_infrastructure.location
  resource_group_name = azurerm_resource_group.core_infrastructure.name
  tags                = var.tags
}

# Jenkins Subnet (equivalent to subnet-jenkins) - FIXED: Use spoke network ranges
resource "azurerm_subnet" "subnet_jenkins" {
  name                 = "subnet-jenkins"
  resource_group_name  = azurerm_resource_group.core_infrastructure.name
  virtual_network_name = azurerm_virtual_network.vpc_spoke.name
  address_prefixes     = ["192.168.1.0/24"]  # Fixed: Use spoke network range
}

# Application Gateway Subnet (equivalent to proxy-only-subnet) - FIXED: Use spoke network ranges
resource "azurerm_subnet" "subnet_appgw" {
  name                 = "subnet-appgw"
  resource_group_name  = azurerm_resource_group.core_infrastructure.name
  virtual_network_name = azurerm_virtual_network.vpc_spoke.name
  address_prefixes     = ["192.168.2.0/24"]  # Fixed: Use spoke network range

  lifecycle {
    ignore_changes = [
      # Ignore changes that might cause conflicts
      delegation,
    ]
  }
}

# VPN Subnet for Firezone Gateway
resource "azurerm_subnet" "subnet_vpn" {
  name                 = "subnet-vpn-v4"
  resource_group_name  = azurerm_resource_group.core_infrastructure.name
  virtual_network_name = azurerm_virtual_network.vpc_spoke.name
  address_prefixes     = [var.vpn_subnet_cidr]
}

# Network Security Group for Jenkins
resource "azurerm_network_security_group" "jenkins_nsg" {
  name                = "${var.name_prefix}jenkins-nsg"
  location            = azurerm_resource_group.core_infrastructure.location
  resource_group_name = azurerm_resource_group.core_infrastructure.name
  tags                = var.tags

  # Allow Azure Bastion access (equivalent to IAP)
  security_rule {
    name                       = "AllowBastionSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Allow Hub traffic (equivalent to allow-hub-traffic)
  security_rule {
    name                       = "AllowHubTraffic"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = var.hub_address_space
    destination_address_prefix = "*"
  }

  # Allow Application Gateway traffic (equivalent to allow-ilb-proxy-traffic) - FIXED: Use spoke network range
  security_rule {
    name                       = "AllowAppGwTraffic"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "80"]
    source_address_prefix      = "192.168.2.0/24"  # Fixed: Use spoke AppGW subnet
    destination_address_prefix = "*"
  }

  # Allow Azure Load Balancer health probes
  security_rule {
    name                       = "AllowAzureLoadBalancer"
    priority                   = 1300
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "AzureLoadBalancer"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Jenkins subnet
resource "azurerm_subnet_network_security_group_association" "jenkins_subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet_jenkins.id
  network_security_group_id = azurerm_network_security_group.jenkins_nsg.id

  depends_on = [
    azurerm_subnet.subnet_jenkins,
    azurerm_network_security_group.jenkins_nsg
  ]
}

# Network Security Group for Application Gateway
resource "azurerm_network_security_group" "appgw_nsg" {
  name                = "${var.name_prefix}appgw-nsg"
  location            = azurerm_resource_group.core_infrastructure.location
  resource_group_name = azurerm_resource_group.core_infrastructure.name
  tags                = var.tags

  # Allow HTTPS inbound
  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP inbound
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Application Gateway management traffic
  security_rule {
    name                       = "AllowGatewayManager"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Application Gateway subnet
resource "azurerm_subnet_network_security_group_association" "appgw_subnet_nsg" {
  subnet_id                 = azurerm_subnet.subnet_appgw.id
  network_security_group_id = azurerm_network_security_group.appgw_nsg.id

  depends_on = [
    azurerm_subnet.subnet_appgw,
    azurerm_network_security_group.appgw_nsg
  ]
}

# VNet Peering from Spoke to Hub
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  count                        = var.enable_hub_peering ? 1 : 0
  name                         = "spoke-to-hub-peering-v4"
  resource_group_name          = azurerm_resource_group.core_infrastructure.name
  virtual_network_name         = azurerm_virtual_network.vpc_spoke.name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.use_remote_gateways
}

# Reverse VNet Peering from Hub to Spoke
resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  count                        = var.enable_hub_peering ? 1 : 0
  name                         = "hub-to-spoke-peering-v4"
  resource_group_name          = var.hub_resource_group_name
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.vpc_spoke.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.hub_has_gateway
  use_remote_gateways          = false

  depends_on = [azurerm_virtual_network_peering.spoke_to_hub]
}

# Private DNS Zone (equivalent to GCP Private DNS Zone)
resource "azurerm_private_dns_zone" "jenkins_dns" {
  name                = var.dns_zone_name
  resource_group_name = azurerm_resource_group.core_infrastructure.name
  tags                = var.tags
}

# Link DNS Zone to Spoke VNet
resource "azurerm_private_dns_zone_virtual_network_link" "spoke_dns_link" {
  name                  = "spoke-dns-link"
  resource_group_name   = azurerm_resource_group.core_infrastructure.name
  private_dns_zone_name = azurerm_private_dns_zone.jenkins_dns.name
  virtual_network_id    = azurerm_virtual_network.vpc_spoke.id
  registration_enabled  = false
  tags                  = var.tags

  depends_on = [
    azurerm_private_dns_zone.jenkins_dns,
    azurerm_virtual_network.vpc_spoke
  ]
}

# Link DNS Zone to Hub VNet (if peering enabled) - ENABLED FOR EXERCISE REQUIREMENTS
resource "azurerm_private_dns_zone_virtual_network_link" "hub_dns_link" {
  count                 = var.enable_hub_peering ? 1 : 0
  name                  = "hub-dns-link"
  resource_group_name   = azurerm_resource_group.core_infrastructure.name
  private_dns_zone_name = azurerm_private_dns_zone.jenkins_dns.name
  virtual_network_id    = var.hub_vnet_id
  registration_enabled  = false
  tags                  = var.tags

  depends_on = [
    azurerm_private_dns_zone.jenkins_dns
  ]
}

# Link DNS Zone to Core IT VNet - DISABLED: Causing conflicts, will be handled separately
# resource "azurerm_private_dns_zone_virtual_network_link" "core_it_dns_link" {
#   name                  = "core-it-dns-link"
#   resource_group_name   = azurerm_resource_group.core_infrastructure.name
#   private_dns_zone_name = azurerm_private_dns_zone.jenkins_dns.name
#   virtual_network_id    = "/subscriptions/95fe2b5a-17cb-4b4c-b5ca-36c90e4dfefd/resourceGroups/${var.name_prefix}core-it-infrastructure-rg/providers/Microsoft.Network/virtualNetworks/${var.name_prefix}az-core-it-infra"
#   registration_enabled  = false
#   tags                  = var.tags

#   depends_on = [
#     azurerm_private_dns_zone.jenkins_dns
#   ]
# }