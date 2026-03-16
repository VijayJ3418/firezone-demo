# Outputs for Multi-Region Firezone Gateway Deployment - WITH INTERNAL LOAD BALANCER

output "firezone_primary" {
  description = "Primary Firezone gateway information"
  value = {
    vm_id             = module.firezone_primary.firezone_gateway.id
    vm_name           = module.firezone_primary.firezone_gateway.name
    private_ip        = module.firezone_primary.firezone_gateway.private_ip_address
    region            = var.primary_region
    instance          = "primary"
    resource_group    = var.primary_resource_group_name
    access_method     = "VPN-only access via internal Load Balancer"
  }
}

output "firezone_secondary" {
  description = "Secondary Firezone gateway information"
  value = {
    vm_id             = module.firezone_secondary.firezone_gateway.id
    vm_name           = module.firezone_secondary.firezone_gateway.name
    private_ip        = module.firezone_secondary.firezone_gateway.private_ip_address
    region            = var.primary_region
    instance          = "secondary"
    resource_group    = var.primary_resource_group_name
    access_method     = "VPN-only access via internal Load Balancer"
  }
}

output "internal_load_balancer" {
  description = "Internal Load Balancer information"
  value = {
    id                = azurerm_lb.firezone_internal_lb.id
    name              = azurerm_lb.firezone_internal_lb.name
    private_ip        = azurerm_lb.firezone_internal_lb.frontend_ip_configuration[0].private_ip_address
    frontend_name     = azurerm_lb.firezone_internal_lb.frontend_ip_configuration[0].name
    backend_pool_id   = azurerm_lb_backend_address_pool.firezone_backend_pool.id
    health_probe_id   = azurerm_lb_probe.firezone_health_probe.id
  }
}

output "firezone_access_info" {
  description = "Firezone access information"
  value = {
    primary_private_ip           = module.firezone_primary.firezone_gateway.private_ip_address
    secondary_private_ip         = module.firezone_secondary.firezone_gateway.private_ip_address
    load_balancer_private_ip     = azurerm_lb.firezone_internal_lb.frontend_ip_configuration[0].private_ip_address
    wireguard_endpoint           = "${azurerm_lb.firezone_internal_lb.frontend_ip_configuration[0].private_ip_address}:51820"
    health_check_url             = "http://${azurerm_lb.firezone_internal_lb.frontend_ip_configuration[0].private_ip_address}:8080"
    deployment_type              = "High availability with internal Load Balancer - VPN-only access"
    token_configured             = "Real Firezone token configured"
    access_note                  = "Access resources only through Firezone VPN connection"
    security_note                = "Internal Load Balancer with private IP - maximum security"
    vpn_setup_note              = "Create VPN client in Firezone admin portal to access resources"
  }
}