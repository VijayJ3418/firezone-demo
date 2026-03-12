# Multi-Region Firezone Gateway Deployment with Load Balancer
# Modified to deploy both gateways in same region (different AZs) for Load Balancer compatibility

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

# Primary Firezone Gateway (Instance 1)
module "firezone_primary" {
  source = "../azure-firezone-gateway"

  name_prefix         = "${var.name_prefix}primary-"
  resource_group_name = var.primary_resource_group_name
  vnet_name          = var.primary_vnet_name
  subnet_name        = var.primary_subnet_name
  vm_size            = var.vm_size
  ssh_public_key     = var.ssh_public_key
  enable_public_ip   = false  # Use load balancer IP
  firezone_token     = var.firezone_token
  log_level          = var.log_level
  tags               = merge(var.tags, { Region = var.primary_region, Instance = "primary" })
}

# Secondary Firezone Gateway (Instance 2) - Deploy in same region/subnet
module "firezone_secondary" {
  source = "../azure-firezone-gateway"

  name_prefix         = "${var.name_prefix}secondary-"
  resource_group_name = var.primary_resource_group_name  # Same region/RG
  vnet_name          = var.primary_vnet_name             # Same VNet
  subnet_name        = var.primary_subnet_name           # Same subnet
  vm_size            = var.vm_size
  ssh_public_key     = var.ssh_public_key
  enable_public_ip   = false  # Use load balancer IP
  firezone_token     = var.firezone_token
  log_level          = var.log_level
  tags               = merge(var.tags, { Region = var.primary_region, Instance = "secondary" })
}

# Public IP for Load Balancer
resource "azurerm_public_ip" "firezone_lb_pip" {
  name                = "${var.name_prefix}firezone-lb-pip"
  location            = var.primary_region
  resource_group_name = var.primary_resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = ["1", "2"]  # Zone redundant
  tags                = var.tags

  lifecycle {
    prevent_destroy = false
    create_before_destroy = true
  }
}

# Load Balancer for Firezone Gateways
resource "azurerm_lb" "firezone_lb" {
  name                = "${var.name_prefix}firezone-lb"
  location            = var.primary_region
  resource_group_name = var.primary_resource_group_name
  sku                 = "Standard"
  tags                = var.tags

  frontend_ip_configuration {
    name                 = "firezone-frontend"
    public_ip_address_id = azurerm_public_ip.firezone_lb_pip.id
  }

  depends_on = [
    azurerm_public_ip.firezone_lb_pip
  ]
}

# Backend Address Pool for Firezone Gateways
resource "azurerm_lb_backend_address_pool" "firezone_backend_pool" {
  loadbalancer_id = azurerm_lb.firezone_lb.id
  name            = "firezone-backend-pool"
}

# Health Probe for Firezone Gateways
resource "azurerm_lb_probe" "firezone_health_probe" {
  loadbalancer_id = azurerm_lb.firezone_lb.id
  name            = "firezone-health-probe"
  port            = 8080
  protocol        = "Http"
  request_path    = "/"
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Load Balancing Rule for WireGuard (UDP)
resource "azurerm_lb_rule" "firezone_wireguard_rule" {
  loadbalancer_id                = azurerm_lb.firezone_lb.id
  name                           = "firezone-wireguard-rule"
  protocol                       = "Udp"
  frontend_port                  = 51820
  backend_port                   = 51820
  frontend_ip_configuration_name = "firezone-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.firezone_backend_pool.id]
  probe_id                       = azurerm_lb_probe.firezone_health_probe.id
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 4
}

# Load Balancing Rule for Health Check (HTTP)
resource "azurerm_lb_rule" "firezone_health_rule" {
  loadbalancer_id                = azurerm_lb.firezone_lb.id
  name                           = "firezone-health-rule"
  protocol                       = "Tcp"
  frontend_port                  = 8080
  backend_port                   = 8080
  frontend_ip_configuration_name = "firezone-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.firezone_backend_pool.id]
  probe_id                       = azurerm_lb_probe.firezone_health_probe.id
  enable_floating_ip             = false
  idle_timeout_in_minutes        = 15
}

# Backend Address Pool Association - Primary (AZ 1)
resource "azurerm_lb_backend_address_pool_address" "firezone_primary_backend" {
  name                    = "firezone-primary-backend"
  backend_address_pool_id = azurerm_lb_backend_address_pool.firezone_backend_pool.id
  virtual_network_id      = var.primary_vnet_id
  ip_address              = module.firezone_primary.firezone_gateway.private_ip_address

  depends_on = [
    module.firezone_primary,
    azurerm_lb_backend_address_pool.firezone_backend_pool
  ]
}

# Backend Address Pool Association - Secondary (AZ 2)
resource "azurerm_lb_backend_address_pool_address" "firezone_secondary_backend" {
  name                    = "firezone-secondary-backend"
  backend_address_pool_id = azurerm_lb_backend_address_pool.firezone_backend_pool.id
  virtual_network_id      = var.primary_vnet_id  # Same VNet now
  ip_address              = module.firezone_secondary.firezone_gateway.private_ip_address

  depends_on = [
    module.firezone_secondary,
    azurerm_lb_backend_address_pool.firezone_backend_pool
  ]
}