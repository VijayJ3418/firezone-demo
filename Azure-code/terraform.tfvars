# Azure Jenkins Infrastructure - Variable Values
# Updated for free trial compatibility

# Basic Configuration
name_prefix = "vijay-"
location    = "Central US"  # Changed back to Central US where infrastructure exists

# VM Configuration - Updated to match working configuration
jenkins_vm_size = "Standard_D2s_v3"  # Working size in Central US

# Network Configuration - UPDATED FOR NEW ARCHITECTURE
hub_address_space     = "172.16.0.0/16"
spoke_address_space   = "192.168.0.0/16"  # Keep existing spoke for other workloads
core_it_address_space = "10.0.0.0/16"     # NEW: Core IT Infrastructure VNet
jenkins_subnet_cidr   = "10.0.1.0/24"     # Jenkins in Core IT VNet
appgw_subnet_cidr     = "10.0.2.0/24"     # Application Gateway in Core IT VNet
vpn_subnet_cidr       = "192.168.131.0/24" # Keep existing for compatibility

# Hub Network Subnets - UPDATED
hub_vpn_subnet_cidr      = "172.16.0.0/24"
hub_firezone_subnet_cidr = "172.16.3.0/24"  # NEW: Firezone gateways in hub
gateway_subnet_cidr      = "172.16.1.0/24"
bastion_subnet_cidr      = "172.16.2.0/24"

# Feature Flags - UPDATED FOR SECURE VPN-ONLY DEPLOYMENT
enable_hub_peering    = true   # Enable hub-spoke peering as per exercise
enable_bastion        = false  # No Bastion - VPN-only access
enable_vpn_gateway    = false  # Disabled to save costs

# Multi-Region Configuration - FIREZONE GATEWAYS ENABLED
enable_firezone_multi_region = true
secondary_region             = "Central US"  # Same region for simplicity
secondary_spoke_address_space = "10.168.0.0/16"
secondary_vpn_subnet_cidr    = "10.168.130.0/24"

# Jenkins Configuration - UPDATED FOR HTTPS ACCESS
jenkins_static_ip = "10.0.1.50"  # Updated for Core IT VNet
jenkins_fqdn      = "jenkins-azure.dglearn.online"  # Updated FQDN as requested
dns_zone_name     = "dglearn.online"

# VPN Configuration - ENABLED FOR FIREZONE
firezone_token = ".SFMyNTY.g2gDaANtAAAAJGM2ZWM0NzVjLWI0ZTUtNDg3OS05M2JiLWRlMjJiM2UxNjgwY20AAAAkNWRiOGIyZjYtZGExNi00Y2ZkLWEwMjQtMjE0YmUzMDNhMTIxbQAAADg0VklSVDQ5VjE5UzVDOE8xVExOUTU5MFVLMVMwTEFUUlZSRTM3QktTNkdFNlAwQ0Y2QkFHPT09PW4GAC-ru_WcAWIAAVGA.S0mFK-XvOjzNafGR80pyAQPH6FDhcvJzLcmxEgr0NeE"  # Latest Firezone token from admin portal - Updated from screenshot
firezone_log_level = "info"  # Log level for Firezone gateways

# SSH Key - UPDATE THIS WITH YOUR ACTUAL PUBLIC KEY
ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDLo7mHJ0g6L3QB3OtZ9Dh7MlR1HcgF0i8mOCnYDtJ92Yn5NL2ASXpf5w0aXp1v7cH1I2Uxg8185vU4i56HJSAa6kEwEh1FGWg1ON+icnvRx2fOAfRTDHfsiTscD/pwxE7JOBReLAoOTNcPMD9p4+1nuP167CFZ5AnZNAoldnavFPxGd/Yn5LYMdj7gPx6SJMwRLeYdOHmokF4DOCfy9OPSEGzDCWhU91fkkkPWkGLTVyp77FturtqsozXmKRsULnVWEsxaU7L/wxyrTRO+2hUeTDp4WBFD23CWj9SjGeP1E7c0zQSuChO6/BQc2w9/aw224tDmyXObs6Z8r4vzLMxRUAjaqq1BBkY71YpPMWi1BP9CK+Jvi5CHaK8WVg2ZgtSMm2ucx/VBrHG0gYhPIEezrhfCHgXXEbcg6+zueGd6D8shMER2lq/Do/0XrjmLe+6gMvNwl4R5TJfupoSrMWyK8g6jOA0a2Ea2b/dNJhbWNibaYMoFi5XWmQmKWuRnyWqbLN+/s6LnxoTo8qgLzXWAD1Ku4ejjxypOkQQw3TXdVB1IND/F7mEU63J4j0nVKZzcZg6Ky1Y7EGe144dAzFd0KnSSd9C3nhIK1AHG5+ZMPAQ8cYG06wWtzgNyL72K9TrWpgQ9M965oK3Aplr7puufSioD4+HIjjXOAGASICrwyw== admin@dglearn.online"

# Tags
tags = {
  Environment = "demo"
  Project     = "jenkins"
  ManagedBy   = "terraform"
  CostCenter  = "learning"
}