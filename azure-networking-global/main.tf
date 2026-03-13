# Azure Networking Global (Hub) - Equivalent to GCP Networkingglobal
# Creates the hub network infrastructure for Azure

# Data sources
data "azurerm_client_config" "current" {}

# Resource Group for Hub Network
resource "azurerm_resource_group" "networking_global" {
  name     = "${var.name_prefix}networking-global-rg"
  location = var.location
  tags     = var.tags
}

# Hub Virtual Network (equivalent to vpc-hub)
resource "azurerm_virtual_network" "vpc_hub" {
  name                = "${var.name_prefix}vpc-hub"
  address_space       = [var.hub_address_space]
  location            = azurerm_resource_group.networking_global.location
  resource_group_name = azurerm_resource_group.networking_global.name
  tags                = var.tags
}

# VPN Gateway Subnet (equivalent to subnet-vpn)
resource "azurerm_subnet" "subnet_vpn" {
  name                 = "subnet-vpn"
  resource_group_name  = azurerm_resource_group.networking_global.name
  virtual_network_name = azurerm_virtual_network.vpc_hub.name
  address_prefixes     = [var.vpn_subnet_cidr]

  depends_on = [azurerm_virtual_network.vpc_hub]
}

# Firezone Subnet for Firezone Gateways
resource "azurerm_subnet" "firezone_subnet" {
  name                 = "firezone-subnet"
  resource_group_name  = azurerm_resource_group.networking_global.name
  virtual_network_name = azurerm_virtual_network.vpc_hub.name
  address_prefixes     = [var.firezone_subnet_cidr]

  depends_on = [azurerm_virtual_network.vpc_hub]
}

# Gateway Subnet for VPN Gateway (required by Azure) - Only create if VPN gateway enabled
resource "azurerm_subnet" "gateway_subnet" {
  count                = var.enable_vpn_gateway ? 1 : 0
  name                 = "GatewaySubnet"  # Must be exactly "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.networking_global.name
  virtual_network_name = azurerm_virtual_network.vpc_hub.name
  address_prefixes     = [var.gateway_subnet_cidr]

  depends_on = [
    azurerm_virtual_network.vpc_hub,
    azurerm_subnet.subnet_vpn
  ]
}

# Network Security Group for Hub
resource "azurerm_network_security_group" "hub_nsg" {
  name                = "${var.name_prefix}hub-nsg-v6"
  location            = azurerm_resource_group.networking_global.location
  resource_group_name = azurerm_resource_group.networking_global.name
  tags                = var.tags

  # INBOUND RULES
  # Allow SSH from VirtualNetwork
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # Allow WireGuard/Firezone traffic from Internet
  security_rule {
    name                       = "AllowWireGuard"
    priority                   = 1100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "51820"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow HTTP for health checks
  security_rule {
    name                       = "AllowHTTPHealthCheck"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }

  # OUTBOUND RULES - CRITICAL FOR INTERNET ACCESS
  # Allow HTTPS outbound for package downloads and Firezone API
  security_rule {
    name                       = "AllowHTTPSOutbound"
    priority                   = 1000
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  # Allow HTTP outbound for package downloads
  security_rule {
    name                       = "AllowHTTPOutbound"
    priority                   = 1100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  # Allow DNS outbound
  security_rule {
    name                       = "AllowDNSOutbound"
    priority                   = 1200
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "53"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }

  # Allow all outbound to VirtualNetwork (for inter-VNet communication)
  security_rule {
    name                       = "AllowVNetOutbound"
    priority                   = 1300
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "VirtualNetwork"
  }

  # Allow NTP outbound (for time synchronization)
  security_rule {
    name                       = "AllowNTPOutbound"
    priority                   = 1400
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Udp"
    source_port_range          = "*"
    destination_port_range     = "123"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

# Associate NSG with Firezone subnet
resource "azurerm_subnet_network_security_group_association" "firezone_subnet_nsg" {
  subnet_id                 = azurerm_subnet.firezone_subnet.id
  network_security_group_id = azurerm_network_security_group.hub_nsg.id

  depends_on = [
    azurerm_subnet.firezone_subnet,
    azurerm_network_security_group.hub_nsg,
    azurerm_virtual_network.vpc_hub
  ]
}

# Public IP for VPN Gateway
resource "azurerm_public_ip" "vpn_gateway_pip" {
  count               = var.enable_vpn_gateway ? 1 : 0
  name                = "${var.name_prefix}vpn-gateway-pip"
  location            = azurerm_resource_group.networking_global.location
  resource_group_name = azurerm_resource_group.networking_global.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

# VPN Gateway (equivalent to Firezone gateway)
resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  count               = var.enable_vpn_gateway ? 1 : 0
  name                = "${var.name_prefix}vpn-gateway"
  location            = azurerm_resource_group.networking_global.location
  resource_group_name = azurerm_resource_group.networking_global.name
  tags                = var.tags

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = var.vpn_gateway_sku

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.vpn_gateway_pip[0].id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet[0].id
  }
}

# Azure Bastion for secure access (equivalent to IAP)
resource "azurerm_subnet" "bastion_subnet" {
  count                = var.enable_bastion ? 1 : 0
  name                 = "AzureBastionSubnet"  # Must be exactly "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.networking_global.name
  virtual_network_name = azurerm_virtual_network.vpc_hub.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

resource "azurerm_public_ip" "bastion_pip" {
  count               = var.enable_bastion ? 1 : 0
  name                = "${var.name_prefix}bastion-pip"
  location            = azurerm_resource_group.networking_global.location
  resource_group_name = azurerm_resource_group.networking_global.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags
}

resource "azurerm_bastion_host" "bastion" {
  count               = var.enable_bastion ? 1 : 0
  name                = "${var.name_prefix}bastion"
  location            = azurerm_resource_group.networking_global.location
  resource_group_name = azurerm_resource_group.networking_global.name
  tags                = var.tags

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_subnet[0].id
    public_ip_address_id = azurerm_public_ip.bastion_pip[0].id
  }
}