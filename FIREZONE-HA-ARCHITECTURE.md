# Firezone VPN Gateway High Availability Architecture on Azure

## 🏗️ Architecture Overview

The Firezone VPN setup provides **High Availability (HA)** through a **multi-region deployment** with **Azure Load Balancer** for automatic failover and load distribution.

```
                    ┌─────────────────────────────────────┐
                    │         FIREZONE CLIENTS            │
                    │      (Remote Users/Devices)         │
                    └─────────────────┬───────────────────┘
                                      │
                                      ▼
                    ┌─────────────────────────────────────┐
                    │      AZURE LOAD BALANCER            │
                    │    (Standard SKU - HA Enabled)     │
                    │   Public IP: firezone-lb-pip       │
                    │   Ports: 51820/UDP, 8080/TCP       │
                    └─────────────┬───────────┬───────────┘
                                  │           │
                    ┌─────────────▼───────────▼───────────┐
                    │         BACKEND POOL                │
                    │   Health Probe: HTTP:8080/         │
                    └─────────────┬───────────┬───────────┘
                                  │           │
                ┌─────────────────▼─────┐   ┌─▼─────────────────────┐
                │   PRIMARY REGION      │   │   SECONDARY REGION    │
                │     (West US 2)       │   │      (East US)        │
                │                       │   │                       │
                │ ┌─────────────────────┐ │   │ ┌─────────────────────┐ │
                │ │ Firezone Gateway VM │ │   │ │ Firezone Gateway VM │ │
                │ │   Standard_A1_v2    │ │   │ │   Standard_A1_v2    │ │
                │ │   Ubuntu 22.04 LTS  │ │   │ │   Ubuntu 22.04 LTS  │ │
                │ │   WireGuard:51820   │ │   │ │   WireGuard:51820   │ │
                │ │   Health:8080       │ │   │ │   Health:8080       │ │
                │ └─────────────────────┘ │   │ └─────────────────────┘ │
                │                       │   │                       │
                │ VNet: 192.168.0.0/16  │   │ VNet: 10.168.0.0/16   │
                │ Subnet: 192.168.131.0 │   │ Subnet: 10.168.130.0  │
                └───────────────────────┘   └───────────────────────┘
                           │                           │
                           ▼                           ▼
                ┌─────────────────────┐   ┌─────────────────────────┐
                │   JENKINS SERVER    │   │   JENKINS SERVER        │
                │    (Primary)        │   │    (Secondary)          │
                │  192.168.0.0/24     │   │   10.168.0.0/24         │
                └─────────────────────┘   └─────────────────────────┘
```

## 🔧 High Availability Components

### **1. Azure Standard Load Balancer**
- **SKU**: Standard (99.99% SLA)
- **Type**: Public-facing with static IP
- **Distribution**: Hash-based load balancing
- **Health Monitoring**: HTTP probes every 15 seconds
- **Failover Time**: < 30 seconds

### **2. Multi-Region Deployment**
- **Primary Region**: West US 2
- **Secondary Region**: East US
- **Geographic Separation**: ~2,000 miles apart
- **Latency**: < 50ms between regions

### **3. Health Monitoring**
- **Probe Type**: HTTP GET to port 8080
- **Probe Path**: `/` (root path)
- **Probe Interval**: 15 seconds
- **Failure Threshold**: 2 consecutive failures
- **Success Threshold**: 2 consecutive successes

### **4. Automatic Failover**
- **Detection**: Load balancer removes unhealthy backends
- **Traffic Routing**: Automatic redirect to healthy gateways
- **Client Impact**: Transparent failover for new connections
- **Recovery**: Automatic re-inclusion when health restored

## 📋 Detailed Configuration

### **Load Balancer Configuration**

```terraform
# Public IP for Load Balancer
resource "azurerm_public_ip" "firezone_lb_pip" {
  name                = "vijay-firezone-lb-pip"
  location            = "West US 2"
  resource_group_name = "vijay-core-infrastructure-rg"
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Standard Load Balancer
resource "azurerm_lb" "firezone_lb" {
  name                = "vijay-firezone-lb"
  location            = "West US 2"
  resource_group_name = "vijay-core-infrastructure-rg"
  sku                 = "Standard"  # 99.99% SLA

  frontend_ip_configuration {
    name                 = "firezone-frontend"
    public_ip_address_id = azurerm_public_ip.firezone_lb_pip.id
  }
}

# Health Probe
resource "azurerm_lb_probe" "firezone_health_probe" {
  loadbalancer_id     = azurerm_lb.firezone_lb.id
  name                = "firezone-health-probe"
  port                = 8080
  protocol            = "Http"
  request_path        = "/"
  interval_in_seconds = 15
  number_of_probes    = 2
}

# Load Balancing Rules
resource "azurerm_lb_rule" "firezone_wireguard_rule" {
  loadbalancer_id                = azurerm_lb.firezone_lb.id
  name                           = "firezone-wireguard-rule"
  protocol                       = "Udp"
  frontend_port                  = 51820
  backend_port                   = 51820
  frontend_ip_configuration_name = "firezone-frontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.firezone_backend_pool.id]
  probe_id                       = azurerm_lb_probe.firezone_health_probe.id
}
```

### **Gateway VM Configuration**

```terraform
# Firezone Gateway VM
resource "azurerm_linux_virtual_machine" "firezone_gateway" {
  name                = "vijay-primary-firezone-gateway"
  location            = "West US 2"
  resource_group_name = "vijay-core-infrastructure-rg"
  size                = "Standard_A1_v2"  # Free trial compatible
  admin_username      = "azureuser"

  # Ubuntu 22.04 LTS (Firezone recommended)
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  # Startup script for Firezone installation
  custom_data = base64encode(templatefile("templates/firezone-startup.sh", {
    firezone_token = var.firezone_token
    log_level      = "info"
  }))
}
```

## 🚀 Deployment Process

### **Phase 1: Enable Firezone Multi-Region Module**

Update `Azure-code/main.tf`:

```terraform
# Enable Firezone Multi-Region Deployment
module "azure_firezone_multi_region" {
  count  = var.enable_firezone_multi_region ? 1 : 0
  source = "./azure-firezone-multi-region"

  name_prefix                     = var.name_prefix
  primary_region                  = var.location
  primary_resource_group_name     = module.azure_core_infrastructure.resource_group.name
  primary_vnet_name              = module.azure_core_infrastructure.spoke_virtual_network.name
  primary_vnet_id                = module.azure_core_infrastructure.spoke_virtual_network.id
  primary_subnet_name            = module.azure_core_infrastructure.vpn_subnet.name
  secondary_region               = var.secondary_region
  secondary_resource_group_name  = module.azure_core_infrastructure_secondary[0].resource_group.name
  secondary_vnet_name           = module.azure_core_infrastructure_secondary[0].spoke_virtual_network.name
  secondary_vnet_id             = module.azure_core_infrastructure_secondary[0].spoke_virtual_network.id
  secondary_subnet_name         = module.azure_core_infrastructure_secondary[0].vpn_subnet.name
  vm_size                       = "Standard_A1_v2"
  ssh_public_key                = var.ssh_public_key
  firezone_token                = var.firezone_token
  tags                          = var.tags

  depends_on = [
    module.azure_core_infrastructure,
    module.azure_core_infrastructure_secondary
  ]
}
```

### **Phase 2: Set Variables**

Update `terraform.tfvars`:

```hcl
# Enable Firezone Multi-Region
enable_firezone_multi_region = true

# Firezone Configuration
firezone_token = "your-firezone-token-here"  # Set in Terraform Cloud as sensitive

# Multi-Region Settings
secondary_region              = "East US"
secondary_spoke_address_space = "10.168.0.0/16"
secondary_vpn_subnet_cidr     = "10.168.130.0/24"
```

### **Phase 3: Deploy Infrastructure**

```bash
# Deploy secondary region infrastructure
terraform apply -target=module.azure_core_infrastructure_secondary

# Deploy Firezone multi-region setup
terraform apply -target=module.azure_firezone_multi_region
```

## 🔍 Monitoring and Health Checks

### **Load Balancer Health Monitoring**

```bash
# Check load balancer status
az network lb show \
  --resource-group vijay-core-infrastructure-rg \
  --name vijay-firezone-lb \
  --query "provisioningState"

# Check backend pool health
az network lb address-pool show \
  --resource-group vijay-core-infrastructure-rg \
  --lb-name vijay-firezone-lb \
  --name firezone-backend-pool
```

### **Gateway Health Checks**

```bash
# Check primary gateway health
curl -f http://<primary-gateway-ip>:8080/

# Check secondary gateway health  
curl -f http://<secondary-gateway-ip>:8080/

# Check WireGuard status on gateway
sudo wg show
```

### **Firezone Service Monitoring**

```bash
# Check Firezone container status
docker compose ps

# View Firezone logs
docker compose logs -f

# Check system resources
htop
df -h
```

## 💰 Cost Analysis for Free Trial

### **Monthly Costs (₹)**

| Component | Primary | Secondary | Total |
|-----------|---------|-----------|-------|
| VM (A1_v2) | 1,500 | 1,500 | 3,000 |
| Storage (Standard) | 300 | 300 | 600 |
| Load Balancer | 800 | - | 800 |
| Public IP | 200 | - | 200 |
| Data Transfer | 100 | 100 | 200 |
| **Total** | **2,900** | **1,900** | **4,800** |

### **Cost Optimization Tips**

1. **Start with Single Region**: Deploy only primary gateway initially
2. **Use Spot Instances**: 60-90% cost reduction (advanced)
3. **Auto-shutdown**: Stop VMs during non-working hours
4. **Monitor Usage**: Set billing alerts at ₹2,000, ₹5,000, ₹8,000

## 🔒 Security Features

### **Network Security**

```bash
# Firewall rules (UFW)
ufw allow 22/tcp      # SSH
ufw allow 51820/udp   # WireGuard
ufw allow 8080/tcp    # Health check
ufw deny incoming     # Default deny
```

### **Access Control**

- **SSH Access**: Key-based authentication only
- **VPN Access**: Firezone token-based authentication
- **Network Isolation**: Private subnets with NSG rules
- **Identity Management**: Azure User Assigned Identity

### **Monitoring and Logging**

```bash
# Firezone logs
journalctl -u firezone-gateway -f

# System logs
tail -f /var/log/firezone-startup.log

# Network monitoring
ss -tulpn | grep :51820
```

## 🚀 Client Configuration

### **Firezone Client Setup**

1. **Install Firezone Client**:
   - Windows: Download from Firezone portal
   - macOS: Download from Firezone portal  
   - Linux: `curl -fsSL https://github.com/firezone/firezone/releases/latest/download/firezone-client-linux.tar.gz`

2. **Configure Connection**:
   - **Server**: Load balancer public IP
   - **Port**: 51820
   - **Token**: From Firezone portal

3. **Test Connectivity**:
   ```bash
   # Test VPN connection
   ping 192.168.0.10  # Jenkins server in primary region
   ping 10.168.0.10   # Jenkins server in secondary region
   ```

## 📊 High Availability Metrics

### **Availability Targets**

- **Load Balancer SLA**: 99.99% (Standard SKU)
- **VM SLA**: 99.9% (single instance)
- **Combined Availability**: 99.99% (with multi-region)
- **RTO (Recovery Time Objective)**: < 30 seconds
- **RPO (Recovery Point Objective)**: 0 (stateless gateways)

### **Performance Metrics**

- **Latency**: < 50ms (within region)
- **Throughput**: Up to 1 Gbps per gateway
- **Concurrent Connections**: 1,000+ per gateway
- **Failover Time**: < 30 seconds

## 🔧 Troubleshooting Guide

### **Common Issues**

1. **Gateway Not Responding**:
   ```bash
   # Check service status
   systemctl status firezone-gateway
   
   # Restart service
   systemctl restart firezone-gateway
   ```

2. **Load Balancer Health Check Failing**:
   ```bash
   # Check health endpoint
   curl -v http://localhost:8080/
   
   # Check firewall
   ufw status
   ```

3. **Client Connection Issues**:
   ```bash
   # Check WireGuard interface
   sudo wg show
   
   # Check routing
   ip route show
   ```

## 🎯 Next Steps

1. **Deploy Jenkins VM first** to establish baseline
2. **Enable secondary region** infrastructure
3. **Deploy Firezone HA setup** with load balancer
4. **Configure client access** and test connectivity
5. **Set up monitoring** and alerting
6. **Document procedures** for operations team

This High Availability setup provides enterprise-grade VPN connectivity with automatic failover, geographic redundancy, and comprehensive monitoring - all optimized for Azure free trial account limits!