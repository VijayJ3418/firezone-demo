# Outputs for Multi-Region Firezone Gateway Deployment - TEMPORARY PUBLIC IPs

output "firezone_primary" {
  description = "Primary Firezone gateway information"
  value = {
    vm_id             = module.firezone_primary.firezone_gateway.id
    vm_name           = module.firezone_primary.firezone_gateway.name
    private_ip        = module.firezone_primary.firezone_gateway.private_ip_address
    public_ip         = module.firezone_primary.public_ip != null ? module.firezone_primary.public_ip.ip_address : null
    region            = var.primary_region
    instance          = "primary"
    resource_group    = var.primary_resource_group_name
    access_method     = "Temporary public IP - will be removed after deployment"
  }
}

output "firezone_secondary" {
  description = "Secondary Firezone gateway information"
  value = {
    vm_id             = module.firezone_secondary.firezone_gateway.id
    vm_name           = module.firezone_secondary.firezone_gateway.name
    private_ip        = module.firezone_secondary.firezone_gateway.private_ip_address
    public_ip         = module.firezone_secondary.public_ip != null ? module.firezone_secondary.public_ip.ip_address : null
    region            = var.primary_region
    instance          = "secondary"
    resource_group    = var.primary_resource_group_name
    access_method     = "Temporary public IP - will be removed after deployment"
  }
}

output "firezone_access_info" {
  description = "Firezone access information"
  value = {
    primary_private_ip           = module.firezone_primary.firezone_gateway.private_ip_address
    secondary_private_ip         = module.firezone_secondary.firezone_gateway.private_ip_address
    primary_public_ip            = module.firezone_primary.public_ip != null ? module.firezone_primary.public_ip.ip_address : null
    secondary_public_ip          = module.firezone_secondary.public_ip != null ? module.firezone_secondary.public_ip.ip_address : null
    primary_ssh_command          = module.firezone_primary.public_ip != null ? "ssh azureuser@${module.firezone_primary.public_ip.ip_address}" : "ssh azureuser@${module.firezone_primary.firezone_gateway.private_ip_address}"
    secondary_ssh_command        = module.firezone_secondary.public_ip != null ? "ssh azureuser@${module.firezone_secondary.public_ip.ip_address}" : "ssh azureuser@${module.firezone_secondary.firezone_gateway.private_ip_address}"
    deployment_type              = "Temporary public IPs for deployment - will be removed for security"
    token_configured             = "Real Firezone token configured"
    next_step                    = "After successful deployment, disable public IPs for security"
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