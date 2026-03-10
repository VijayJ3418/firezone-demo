# Azure Firezone Gateway Configuration
# Equivalent to GCP terraform-google-gateway module

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

# Data sources
data "azurerm_client_config" "current" {}

data "azurerm_availability_zones" "available" {
  location = var.location
}

# Local variables
locals {
  tags = merge({
    managed_by  = "terraform"
    application = "firezone-gateway"
  }, var.tags)

  # Azure Load Balancer health probe IP ranges
  azure_health_probe_ip_ranges = [
    "168.63.129.16/32"
  ]

  availability_zones = length(var.availability_zones) == 0 ? data.azurerm_availability_zones.available.names : var.availability_zones
}

# Resource Group
resource "azurerm_resource_group" "firezone" {
  name     = "${var.name_prefix}firezone-gateway-rg"
  location = var.location
  tags     = local.tags
}

# User Assigned Identity for VM Scale Set
resource "azurerm_user_assigned_identity" "firezone" {
  name                = "${var.name_prefix}firezone-gateway-identity"
  location            = azurerm_resource_group.firezone.location
  resource_group_name = azurerm_resource_group.firezone.name
  tags                = local.tags
}

# Network Security Group
resource "azurerm_network_security_group" "firezone" {
  name                = "${var.name_prefix}firezone-gateway-nsg"
  location            = azurerm_resource_group.firezone.location
  resource_group_name = azurerm_resource_group.firezone.name
  tags                = local.tags

  # Allow health probe traffic
  security_rule {
    name                       = "AllowHealthProbe"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = var.health_check.port
    source_address_prefixes    = local.azure_health_probe_ip_ranges
    destination_address_prefix = "*"
  }

  # Allow WireGuard traffic (if needed)
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

  # Allow SSH for management
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Virtual Machine Scale Set
resource "azurerm_linux_virtual_machine_scale_set" "firezone" {
  name                = "${var.name_prefix}firezone-gateway-vmss"
  location            = azurerm_resource_group.firezone.location
  resource_group_name = azurerm_resource_group.firezone.name
  sku                 = var.vm_size
  instances           = var.instance_count
  
  # Enable IP forwarding for gateway functionality
  upgrade_mode = "Manual"
  
  tags = local.tags

  # Availability zones
  zones = local.availability_zones

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = var.os_disk_type
    caching              = "ReadWrite"
  }

  network_interface {
    name                          = "internal"
    primary                       = true
    enable_ip_forwarding         = true
    network_security_group_id    = azurerm_network_security_group.firezone.id

    ip_configuration {
      name      = "internal"
      primary   = true
      subnet_id = var.subnet_id

      # Public IP configuration (optional)
      dynamic "public_ip_address" {
        for_each = var.enable_public_ip ? [1] : []
        content {
          name = "public"
        }
      }
    }
  }

  # Admin user configuration
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  # User assigned identity
  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.firezone.id]
  }

  # Custom data for cloud-init
  custom_data = base64encode(templatefile("${path.module}/templates/cloud-init.yaml", {
    firezone_token        = var.firezone_token
    firezone_api_url      = var.firezone_api_url
    firezone_version      = var.firezone_version
    firezone_artifact_url = var.firezone_artifact_url
    log_level            = var.log_level
    log_format           = var.log_format
    swap_size_gb         = var.swap_size_gb
  }))

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    azurerm_user_assigned_identity.firezone
  ]
}

# Application Gateway for load balancing (optional)
resource "azurerm_public_ip" "gateway" {
  count               = var.enable_load_balancer ? 1 : 0
  name                = "${var.name_prefix}firezone-gateway-pip"
  location            = azurerm_resource_group.firezone.location
  resource_group_name = azurerm_resource_group.firezone.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_application_gateway" "firezone" {
  count               = var.enable_load_balancer ? 1 : 0
  name                = "${var.name_prefix}firezone-gateway-appgw"
  location            = azurerm_resource_group.firezone.location
  resource_group_name = azurerm_resource_group.firezone.name
  tags                = local.tags

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = var.gateway_subnet_id
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.gateway[0].id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "backend-http-settings"
    cookie_based_affinity = "Disabled"
    port                  = var.health_check.port
    protocol              = "Http"
    request_timeout       = 60
    
    probe_name = "health-probe"
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "frontend-port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "backend-http-settings"
    priority                   = 1
  }

  probe {
    name                = "health-probe"
    protocol            = "Http"
    path                = var.health_check.path
    host                = "127.0.0.1"
    interval            = var.health_check.interval_seconds
    timeout             = var.health_check.timeout_seconds
    unhealthy_threshold = var.health_check.unhealthy_threshold
  }
}

# Associate VMSS with Application Gateway backend pool
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "firezone" {
  count                   = var.enable_load_balancer ? var.instance_count : 0
  network_interface_id    = azurerm_linux_virtual_machine_scale_set.firezone.network_interface[0].id
  ip_configuration_name   = "internal"
  backend_address_pool_id = azurerm_application_gateway.firezone[0].backend_address_pool[0].id
}