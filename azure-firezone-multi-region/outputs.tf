# Outputs for Multi-Region Firezone Gateway Deployment - SIMPLIFIED

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
  }
}

output "firezone_access_info" {
  description = "Firezone access information"
  value = {
    primary_wireguard_endpoint   = module.firezone_primary.public_ip != null ? "${module.firezone_primary.public_ip.ip_address}:51820" : "No public IP"
    secondary_wireguard_endpoint = module.firezone_secondary.public_ip != null ? "${module.firezone_secondary.public_ip.ip_address}:51820" : "No public IP"
    primary_health_check_url     = module.firezone_primary.public_ip != null ? "http://${module.firezone_primary.public_ip.ip_address}:8080" : "No public IP"
    secondary_health_check_url   = module.firezone_secondary.public_ip != null ? "http://${module.firezone_secondary.public_ip.ip_address}:8080" : "No public IP"
    primary_ssh_command          = module.firezone_primary.public_ip != null ? "ssh azureuser@${module.firezone_primary.public_ip.ip_address}" : "Use private IP"
    secondary_ssh_command        = module.firezone_secondary.public_ip != null ? "ssh azureuser@${module.firezone_secondary.public_ip.ip_address}" : "Use private IP"
    deployment_type              = "Dual gateway deployment with individual public IPs"
    token_configured             = "Real Firezone token configured"
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