# Azure Firezone Gateway Outputs
# Equivalent to GCP terraform-google-gateway outputs

output "resource_group" {
  description = "The resource group containing all Firezone resources"
  value = {
    name     = azurerm_resource_group.firezone.name
    location = azurerm_resource_group.firezone.location
    id       = azurerm_resource_group.firezone.id
  }
}

output "user_assigned_identity" {
  description = "The user assigned identity for Firezone VMs"
  value = {
    id           = azurerm_user_assigned_identity.firezone.id
    principal_id = azurerm_user_assigned_identity.firezone.principal_id
    client_id    = azurerm_user_assigned_identity.firezone.client_id
  }
}

output "virtual_machine_scale_set" {
  description = "The virtual machine scale set running Firezone gateways"
  value = {
    id       = azurerm_linux_virtual_machine_scale_set.firezone.id
    name     = azurerm_linux_virtual_machine_scale_set.firezone.name
    location = azurerm_linux_virtual_machine_scale_set.firezone.location
  }
}

output "network_security_group" {
  description = "The network security group for Firezone gateways"
  value = {
    id   = azurerm_network_security_group.firezone.id
    name = azurerm_network_security_group.firezone.name
  }
}

output "application_gateway" {
  description = "The application gateway for load balancing (if enabled)"
  value = var.enable_load_balancer ? {
    id         = azurerm_application_gateway.firezone[0].id
    name       = azurerm_application_gateway.firezone[0].name
    public_ip  = azurerm_public_ip.gateway[0].ip_address
    fqdn       = azurerm_public_ip.gateway[0].fqdn
  } : null
}

output "public_ip" {
  description = "Public IP address of the Application Gateway (if load balancer is enabled)"
  value       = var.enable_load_balancer ? azurerm_public_ip.gateway[0].ip_address : null
}

output "gateway_endpoints" {
  description = "Gateway connection endpoints"
  value = {
    public_endpoint  = var.enable_load_balancer ? azurerm_public_ip.gateway[0].ip_address : null
    health_check_url = var.enable_load_balancer ? "http://${azurerm_public_ip.gateway[0].ip_address}${var.health_check.path}" : null
  }
}