# Azure Jenkins Infrastructure - Root Outputs

# Hub Network Output - ENABLED FOR EXERCISE REQUIREMENTS
output "hub_network" {
  description = "Hub network information"
  value       = module.azure_networking_global
}

# Core IT Infrastructure Output - NEW: Dedicated VNet for Jenkins
output "core_it_infrastructure" {
  description = "Core IT Infrastructure information"
  value       = module.azure_core_it_infrastructure
}

# Spoke Network Output - Available for other workloads
output "spoke_network" {
  description = "Spoke network information"
  value       = module.azure_core_infrastructure
}

# Jenkins VM Output - Updated for Core IT Infrastructure
output "jenkins_vm" {
  description = "Jenkins VM information"
  value       = module.azure_jenkins_vm
  sensitive   = true
}

# Firezone Multi-Region Outputs - Updated for Hub Network
output "firezone_multi_region" {
  description = "Multi-region Firezone VPN gateway deployment information"
  value       = var.enable_firezone_multi_region ? module.azure_firezone_multi_region[0] : null
  sensitive   = true
}

# Jenkins Access Information - Updated for new architecture
output "jenkins_access_info" {
  description = "Information for accessing Jenkins"
  value = {
    jenkins_private_ip    = module.azure_jenkins_vm.jenkins_vm.private_ip_address
    jenkins_subnet        = module.azure_core_it_infrastructure.jenkins_subnet.name
    resource_group        = module.azure_core_it_infrastructure.resource_group.name
    core_it_vnet          = module.azure_core_it_infrastructure.core_it_virtual_network.name
    ssh_command          = "ssh azureuser@${module.azure_jenkins_vm.jenkins_vm.private_ip_address}"
    jenkins_url          = "http://${module.azure_jenkins_vm.jenkins_vm.private_ip_address}:8080"
    jenkins_https_url    = "https://jenkins-azure.dglearn.online"
    access_method        = "VPN-only access through Firezone or Application Gateway"
  }
}

# Application Gateway Output - ENABLED
output "application_gateway" {
  description = "Application Gateway information for HTTPS access"
  value = {
    id                = module.azure_jenkins_appgw.application_gateway.id
    name              = module.azure_jenkins_appgw.application_gateway.name
    private_ip        = module.azure_jenkins_appgw.application_gateway.private_ip_address
    public_ip         = module.azure_jenkins_appgw.application_gateway.public_ip_address
    jenkins_https_url = module.azure_jenkins_appgw.jenkins_access_info.fqdn_url
  }
}

# Architecture Summary
output "architecture_summary" {
  description = "Summary of the deployed architecture"
  value = {
    hub_network           = "az-networking-global (172.16.0.0/16) - Firezone gateways"
    core_it_network       = "az-core-it-infra (10.0.0.0/16) - Jenkins VM + Application Gateway"
    spoke_network         = "spoke-network (192.168.0.0/16) - Available for other workloads"
    firezone_location     = "Hub network (172.16.3.0/24)"
    jenkins_location      = "Core IT network (10.0.1.0/24)"
    https_access          = "https://jenkins-azure.dglearn.online"
    vpn_access           = "Through Firezone VPN gateways in hub network"
  }
}