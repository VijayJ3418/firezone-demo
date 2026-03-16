# Architecture Fix Plan - Correct VNet Placement

## 🎯 Current Issues & Required Changes

### Issue 1: Incorrect VNet Placement
- **Current**: Firezone gateways in spoke VNet, Jenkins in spoke VNet
- **Required**: Firezone gateways in hub VNet (az-networking-global), Jenkins in separate core-it-infra VNet

### Issue 2: Missing HTTPS Access
- **Current**: No HTTPS access to Jenkins
- **Required**: `https://jenkins-azure.dglearn.online` with Application Gateway

### Issue 3: Missing Firewall Rules
- **Current**: No specific SSH access rules
- **Required**: SSH access from `35.235.240.0/20` and `20.20.20.20/16`

## 🏗️ New Architecture Design

```
Hub Network (az-networking-global) - 172.16.0.0/16
├── Gateway Subnet (172.16.1.0/24) - Azure VPN Gateway (if enabled)
├── Bastion Subnet (172.16.2.0/24) - Azure Bastion (if enabled)
└── Firezone Subnet (172.16.3.0/24) - Firezone Gateways + Load Balancer

Core-IT-Infrastructure VNet - 10.0.0.0/16
├── Jenkins Subnet (10.0.1.0/24) - Jenkins VM
└── AppGW Subnet (10.0.2.0/24) - Application Gateway

Spoke Network (existing) - 192.168.0.0/16
└── Can be used for other workloads
```

## 📋 Implementation Steps

### Step 1: Create Core-IT-Infrastructure Module
- New VNet: `az-core-it-infra` (10.0.0.0/16)
- Jenkins subnet: 10.0.1.0/24
- Application Gateway subnet: 10.0.2.0/24
- VNet peering with hub network

### Step 2: Move Firezone to Hub Network
- Update Firezone deployment to use hub VNet
- Create Firezone subnet in hub network
- Update Load Balancer configuration

### Step 3: Add Application Gateway
- HTTPS termination
- Custom domain: jenkins-azure.dglearn.online
- Backend pool pointing to Jenkins VM

### Step 4: Update Network Security Groups
- SSH access from specified IP ranges
- HTTPS access through Application Gateway
- Firezone VPN access rules

### Step 5: DNS Configuration
- A record: jenkins-azure.dglearn.online → Application Gateway IP
- SSL certificate configuration

## 🚀 Benefits of New Architecture

✅ **Proper Segmentation**: Each service in correct VNet
✅ **HTTPS Access**: Secure access via Application Gateway
✅ **VPN Integration**: Firezone in hub for centralized access
✅ **Security**: Controlled access via firewall rules
✅ **Scalability**: Separate VNets for different workloads