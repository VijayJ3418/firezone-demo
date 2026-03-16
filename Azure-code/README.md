# Azure Jenkins Infrastructure - Hub-Spoke Architecture

This project deploys a complete Azure infrastructure with hub-spoke network architecture and Jenkins VM.

## 🏗️ Architecture

```
Hub Network (172.16.0.0/16)
├── subnet-vpn (172.16.0.0/24)
└── NSG: vijay-hub-nsg-v5

        ↕ VNet Peering ↕

Spoke Network (192.168.0.0/16)
├── subnet-jenkins (192.168.0.0/24) → Jenkins VM
├── subnet-appgw (192.168.128.0/23)
├── subnet-vpn-v4 (192.168.131.0/24)
└── DNS Zone: dglearn.online
```

## 🚀 Quick Start

### 1. Prerequisites
- Azure CLI installed and logged in
- Terraform installed
- SSH key pair generated

### 2. Setup
```bash
# Update terraform.tfvars with your SSH public key
# Replace REPLACE_WITH_YOUR_SSH_PUBLIC_KEY with your actual key

# Clean up any existing resources
chmod +x destroy-all-resources.sh
./destroy-all-resources.sh

# Deploy infrastructure
chmod +x deploy-exercise.sh
./deploy-exercise.sh
```

### 3. Access Jenkins
After deployment:
```bash
# SSH to Jenkins VM
ssh azureuser@<jenkins-private-ip>

# Get Jenkins initial password
sudo cat /jenkins/jenkins_home/secrets/initialAdminPassword

# Access Jenkins web interface
http://<jenkins-private-ip>:8080
```

## 📁 Project Structure

```
Azure-code/
├── main.tf                           # Root configuration
├── variables.tf                      # Root variables
├── outputs.tf                        # Root outputs
├── terraform.tfvars                  # Variable values
├── azure-networking-global/          # Hub network module
├── azure-core-infrastructure/        # Spoke network module
├── azure-jenkins-vm/                 # Jenkins VM module
├── deploy-exercise.sh                # Deployment script
├── destroy-all-resources.sh          # Cleanup script
└── README.md                         # This file
```

## 💰 Estimated Cost
- VM (Standard_A1): ₹1,000-1,500/month
- Storage: ₹300-500/month
- Networking: ₹200-400/month
- **Total**: ₹1,500-2,400/month

## 🔧 Troubleshooting

### VM Size Issues
The deployment script tries multiple VM sizes:
1. Standard_A1 (recommended for free trial)
2. Standard_A0 (minimal)
3. Standard_B1ls (burstable)
4. Standard_F1s (compute optimized)

### Common Issues
- **Quota exceeded**: Contact Azure support
- **Region unavailable**: Try different regions
- **SSH key error**: Update terraform.tfvars with valid SSH public key