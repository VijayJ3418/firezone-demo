# Azure Core IT Infrastructure Module
# Creates dedicated VNet for Jenkins and related IT infrastructure

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

# Data sources
data "azurerm_client_config" "current" {}

# Resource Group for Core IT Infrastructure
resource "azurerm_resource_group" "core_it_rg" {
  name     = "${var.name_prefix}core-it-infrastructure-rg"
  location = var.location
  tags     = var.tags
}

# Core IT Infrastructure Virtual Network
resource "azurerm_virtual_network" "core_it_vnet" {
  name                = "${var.name_prefix}az-core-it-infra"
  location            = azurerm_resource_group.core_it_rg.location
  resource_group_name = azurerm_resource_group.core_it_rg.name
  address_space       = [var.core_it_address_space]
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

# Jenkins Subnet
resource "azurerm_subnet" "jenkins_subnet" {
  name                 = "jenkins-subnet"
  resource_group_name  = azurerm_resource_group.core_it_rg.name
  virtual_network_name = azurerm_virtual_network.core_it_vnet.name
  address_prefixes     = [var.jenkins_subnet_cidr]
}

# Application Gateway Subnet
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.core_it_rg.name
  virtual_network_name = azurerm_virtual_network.core_it_vnet.name
  address_prefixes     = [var.appgw_subnet_cidr]
}

# Network Security Group for Jenkins
resource "azurerm_network_security_group" "jenkins_nsg" {
  name                = "${var.name_prefix}jenkins-nsg"
  location            = azurerm_resource_group.core_it_rg.location
  resource_group_name = azurerm_resource_group.core_it_rg.name
  tags                = var.tags

  # SSH access from specified IP ranges
  security_rule {
    name                       = "SSH-GCP-Range"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "35.235.240.0/20"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "SSH-Firezone-Range"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "20.20.0.0/16"
    destination_address_prefix = "*"
  }

  # Jenkins HTTP access from Application Gateway subnet
  security_rule {
    name                       = "Jenkins-HTTP-AppGW"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = var.appgw_subnet_cidr
    destination_address_prefix = "*"
  }

  # Jenkins HTTPS access from Application Gateway subnet
  security_rule {
    name                       = "Jenkins-HTTPS-AppGW"
    priority                   = 1004
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8443"
    source_address_prefix      = var.appgw_subnet_cidr
    destination_address_prefix = "*"
  }

  # Allow access from Firezone VPN subnet (hub network)
  security_rule {
    name                       = "Jenkins-Firezone-VPN"
    priority                   = 1005
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_ranges    = ["8080", "8443", "22"]
    source_address_prefix      = var.hub_firezone_subnet_cidr
    destination_address_prefix = "*"
  }
}

# Network Security Group for Application Gateway
resource "azurerm_network_security_group" "appgw_nsg" {
  name                = "${var.name_prefix}appgw-nsg"
  location            = azurerm_resource_group.core_it_rg.location
  resource_group_name = azurerm_resource_group.core_it_rg.name
  tags                = var.tags

  # HTTPS access from internet (through Firezone VPN)
  security_rule {
    name                       = "HTTPS-Internet"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # HTTP redirect to HTTPS
  security_rule {
    name                       = "HTTP-Redirect"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Application Gateway management ports
  security_rule {
    name                       = "AppGW-Management"
    priority                   = 1003
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "65200-65535"
    source_address_prefix      = "GatewayManager"
    destination_address_prefix = "*"
  }
}

# Associate NSG with Jenkins subnet
resource "azurerm_subnet_network_security_group_association" "jenkins_nsg_association" {
  subnet_id                 = azurerm_subnet.jenkins_subnet.id
  network_security_group_id = azurerm_network_security_group.jenkins_nsg.id
}

# Associate NSG with Application Gateway subnet
resource "azurerm_subnet_network_security_group_association" "appgw_nsg_association" {
  subnet_id                 = azurerm_subnet.appgw_subnet.id
  network_security_group_id = azurerm_network_security_group.appgw_nsg.id
}

# VNet Peering to Hub Network
resource "azurerm_virtual_network_peering" "core_it_to_hub" {
  count                        = var.enable_hub_peering ? 1 : 0
  name                         = "core-it-to-hub-peering"
  resource_group_name          = azurerm_resource_group.core_it_rg.name
  virtual_network_name         = azurerm_virtual_network.core_it_vnet.name
  remote_virtual_network_id    = var.hub_vnet_id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = var.hub_has_gateway && var.use_remote_gateways
}

# VNet Peering from Hub to Core IT
resource "azurerm_virtual_network_peering" "hub_to_core_it" {
  count                        = var.enable_hub_peering ? 1 : 0
  name                         = "hub-to-core-it-peering"
  resource_group_name          = var.hub_resource_group_name
  virtual_network_name         = var.hub_vnet_name
  remote_virtual_network_id    = azurerm_virtual_network.core_it_vnet.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = var.hub_has_gateway
  use_remote_gateways          = false
}

# DNS Zone - DISABLED: Avoid conflict with spoke network DNS zone
# Only spoke network should create the DNS zone to prevent conflicts
# resource "azurerm_private_dns_zone" "core_it_dns" {
#   count               = var.dns_zone_name != "" ? 1 : 0
#   name                = var.dns_zone_name
#   resource_group_name = azurerm_resource_group.core_it_rg.name
#   tags                = var.tags
# }

# Link DNS zone to Core IT VNet - DISABLED: Use spoke network DNS zone
# resource "azurerm_private_dns_zone_virtual_network_link" "core_it_dns_link" {
#   count                 = var.dns_zone_name != "" ? 1 : 0
#   name                  = "${var.name_prefix}core-it-dns-link"
#   resource_group_name   = azurerm_resource_group.core_it_rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.core_it_dns[0].name
#   virtual_network_id    = azurerm_virtual_network.core_it_vnet.id
#   tags                  = var.tags
# }

# Link DNS zone to Hub VNet - DISABLED: Use spoke network DNS zone
# resource "azurerm_private_dns_zone_virtual_network_link" "hub_dns_link" {
#   count                 = var.dns_zone_name != "" && var.enable_hub_peering ? 1 : 0
#   name                  = "${var.name_prefix}hub-dns-link"
#   resource_group_name   = azurerm_resource_group.core_it_rg.name
#   private_dns_zone_name = azurerm_private_dns_zone.core_it_dns[0].name
#   virtual_network_id    = var.hub_vnet_id
#   tags                  = var.tags
# }