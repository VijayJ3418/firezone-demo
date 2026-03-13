# Outputs for Multi-Region Firezone Gateway Deployment - PRIVATE GATEWAYS

output "firezone_primary" {
  description = "Primary Firezone gateway information"
  value = {
    vm_id             = module.firezone_primary.firezone_gateway.id
    vm_name           = module.firezone_primary.firezone_gateway.name
    private_ip        = module.firezone_primary.firezone_gateway.private_ip_address
    region            = var.primary_region
    instance          = "primary"
    resource_group    = var.primary_resource_group_name
    access_method     = "Private IP only - access via Jenkins VM or VPN"
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
    access_method     = "Private IP only - access via Jenkins VM or VPN"
  }
}

output "firezone_access_info" {
  description = "Firezone access information"
  value = {
    primary_private_ip           = module.firezone_primary.firezone_gateway.private_ip_address
    secondary_private_ip         = module.firezone_secondary.firezone_gateway.private_ip_address
    primary_ssh_command          = "ssh azureuser@${module.firezone_primary.firezone_gateway.private_ip_address}"
    secondary_ssh_command        = "ssh azureuser@${module.firezone_secondary.firezone_gateway.private_ip_address}"
    deployment_type              = "Private dual gateway deployment (no public IPs)"
    token_configured             = "Real Firezone token configured"
    access_note                  = "Access gateways via Jenkins VM or establish VPN connection first"
    security_note                = "Gateways are private - no direct internet access for security"
  }
}

# LOAD BALANCER OUTPUTS DISABLED
# Uncomment if Load Balancer is re-enabled later

# output "load_balancer" {
#   description = "Firezone load balancer information"
#   value = {
#     id                = azurerm_lb.firezone_lb.id
#     name              = azurerm_lb.firezone_lb.name
#     public_ip_address = azurerm_public_ip.firezone_lb_pip.ip_address
#     fqdn              = azurerm_public_ip.firezone_lb_pip.fqdn
#   }
# }