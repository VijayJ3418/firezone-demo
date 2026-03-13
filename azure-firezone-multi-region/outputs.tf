# Outputs for Multi-Region Firezone Gateway Deployment - PRIVATE ONLY

output "firezone_primary" {
  description = "Primary Firezone gateway information"
  value = {
    vm_id             = module.firezone_primary.firezone_gateway.id
    vm_name           = module.firezone_primary.firezone_gateway.name
    private_ip        = module.firezone_primary.firezone_gateway.private_ip_address
    region            = var.primary_region
    instance          = "primary"
    resource_group    = var.primary_resource_group_name
    access_method     = "VPN-only access - no public IP"
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
    access_method     = "VPN-only access - no public IP"
  }
}

output "firezone_access_info" {
  description = "Firezone access information"
  value = {
    primary_private_ip           = module.firezone_primary.firezone_gateway.private_ip_address
    secondary_private_ip         = module.firezone_secondary.firezone_gateway.private_ip_address
    deployment_type              = "Private dual gateway deployment - VPN-only access"
    token_configured             = "Real Firezone token configured"
    access_note                  = "Access resources only through Firezone VPN connection"
    security_note                = "No public IPs - maximum security configuration"
    vpn_setup_note              = "Create VPN client in Firezone admin portal to access resources"
  }
}