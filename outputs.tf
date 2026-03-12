# Azure Jenkins Infrastructure - Root Outputs

# Hub Network Output - ENABLED FOR EXERCISE REQUIREMENTS
output "hub_network" {
  description = "Hub network information"
  value       = module.azure_networking_global
}

# Spoke Network Output - Always available
output "spoke_network" {
  description = "Spoke network information"
  value       = module.azure_core_infrastructure
}

# Jenkins VM Output - Enabled
output "jenkins_vm" {
  description = "Jenkins VM information"
  value       = module.azure_jenkins_vm
  sensitive   = true
}

# Firezone Multi-Region Outputs - DISABLED TEMPORARILY
# output "firezone_multi_region" {
#   description = "Multi-region Firezone VPN gateway deployment information"
#   value       = var.enable_firezone_multi_region ? module.azure_firezone_multi_region[0] : null
#   sensitive   = true
# }

# output "secondary_infrastructure" {
#   description = "Secondary region infrastructure information for Firezone"
#   value       = var.enable_firezone_multi_region ? module.azure_core_infrastructure_secondary[0] : null
# }

# output "application_gateway" {
#   description = "Application Gateway information"
#   value       = module.azure_jenkins_appgw
# }

# Jenkins Access Information
output "jenkins_access_info" {
  description = "Information for accessing Jenkins"
  value = {
    jenkins_private_ip    = module.azure_jenkins_vm.jenkins_vm.private_ip_address
    jenkins_subnet        = module.azure_core_infrastructure.jenkins_subnet.name
    resource_group        = module.azure_core_infrastructure.resource_group.name
    ssh_command          = "ssh azureuser@${module.azure_jenkins_vm.jenkins_vm.private_ip_address}"
    jenkins_url          = "http://${module.azure_jenkins_vm.jenkins_vm.private_ip_address}:8080"
  }
}