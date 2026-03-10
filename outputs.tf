# Azure Jenkins Infrastructure - Root Outputs

output "hub_network" {
  description = "Hub network information"
  value       = module.azure_networking_global
}

output "spoke_network" {
  description = "Spoke network information"
  value       = module.azure_core_infrastructure
}

output "jenkins_vm" {
  description = "Jenkins VM information"
  value       = module.azure_jenkins_vm
  sensitive   = true
}

output "application_gateway" {
  description = "Application Gateway information"
  value       = module.azure_jenkins_appgw
}

output "jenkins_access_info" {
  description = "Information for accessing Jenkins"
  value = {
    jenkins_url           = "https://${var.jenkins_fqdn}"
    application_gateway_ip = var.jenkins_static_ip
    bastion_access        = module.azure_networking_global.bastion_host
  }
}