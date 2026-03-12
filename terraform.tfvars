# Azure Jenkins Infrastructure - Variable Values
# Updated for free trial compatibility

# Basic Configuration
name_prefix = "vijay-"
location    = "Central US"  # Changed back to Central US where infrastructure exists

# VM Configuration - Free Trial Optimized
jenkins_vm_size = "Standard_B1ms"  # B1ms is often available in free trials

# Network Configuration
hub_address_space     = "172.16.0.0/16"
spoke_address_space   = "192.168.0.0/16"
jenkins_subnet_cidr   = "192.168.0.0/24"
appgw_subnet_cidr     = "192.168.128.0/23"
vpn_subnet_cidr       = "192.168.131.0/24"

# Hub Network Subnets
hub_vpn_subnet_cidr   = "172.16.0.0/24"
gateway_subnet_cidr   = "172.16.1.0/24"
bastion_subnet_cidr   = "172.16.2.0/24"

# Feature Flags - RESTORED FOR ORIGINAL EXERCISE
enable_hub_peering    = true   # Enable hub-spoke peering as per exercise
enable_bastion        = false  # Disabled to save costs
enable_vpn_gateway    = false  # Disabled to save costs

# Multi-Region Configuration - ENABLED FOR LOAD BALANCER SETUP
enable_firezone_multi_region = true
secondary_region             = "Central US"  # Same region for Load Balancer compatibility
secondary_spoke_address_space = "10.168.0.0/16"
secondary_vpn_subnet_cidr    = "10.168.130.0/24"

# Jenkins Configuration
jenkins_static_ip = "192.168.129.50"
jenkins_fqdn      = "jenkins.np.dglearn.online"
dns_zone_name     = "dglearn.online"

# VPN Configuration - ENABLED FOR FIREZONE
firezone_token = "demo-token-for-testing"  # Replace with actual token later

# SSH Key - REPLACE WITH YOUR ACTUAL PUBLIC KEY
ssh_public_key = "REPLACE_WITH_YOUR_SSH_PUBLIC_KEY"

# Tags
tags = {
  Environment = "demo"
  Project     = "jenkins"
  ManagedBy   = "terraform"
  CostCenter  = "learning"
}