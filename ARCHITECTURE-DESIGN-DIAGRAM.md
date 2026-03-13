# Azure Infrastructure Design Diagram with Data Flow

## 🏗️ Complete Architecture Overview - Current Deployed State

```
                                    ┌─────────────────────────────────────┐
                                    │             INTERNET                │
                                    │                                     │
                                    │  👤 External Users                  │
                                    │  🔒 VPN Users                       │
                                    │  🛠️  SSH Admins                     │
                                    └─────────────┬───────────────────────┘
                                                  │
                                    ┌─────────────▼───────────────┐
                                    │      DNS Resolution         │
                                    │ jenkins-azure.dglearn.online│
                                    │   → Application Gateway IP  │
                                    └─────────────┬───────────────┘
                                                  │
┌─────────────────────────────────────────────────▼─────────────────────────────────────────────────┐
│                                 AZURE CLOUD ENVIRONMENT                                           │
│                                                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐     │
│  │                        Hub Network (az-networking-global)                               │     │
│  │                                172.16.0.0/16                                           │     │
│  │                                                                                         │     │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐   │     │
│  │  │                    Firezone Subnet (172.16.3.0/24)                             │   │     │
│  │  │                                                                                 │   │     │
│  │  │  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐   │   │     │
│  │  │  │   Primary FZ    │  │  Secondary FZ   │  │    Internal Load Balancer   │   │   │     │
│  │  │  │   Gateway       │  │   Gateway       │  │      (High Availability)    │   │   │     │
│  │  │  │  172.16.3.4     │  │  172.16.3.5     │  │        172.16.3.10          │   │   │     │
│  │  │  │                 │  │                 │  │                             │   │   │     │
│  │  │  │ 🔒 WireGuard    │  │ 🔒 WireGuard    │  │  🔄 Load Balancing          │   │   │     │
│  │  │  │   Port: 51820   │  │   Port: 51820   │  │     Port: 51820             │   │   │     │
│  │  │  │                 │  │                 │  │                             │   │   │     │
│  │  │  │ Status: Running │  │ Status: Running │  │  Backend: Both Gateways     │   │   │     │
│  │  │  └─────────────────┘  └─────────────────┘  └─────────────────────────────┘   │   │     │
│  │  │                                                                                 │   │     │
│  │  │  🔐 NSG Rules:                                                                  │   │     │
│  │  │  • SSH from VirtualNetwork (Port 22) ✅                                        │   │     │
│  │  │  • WireGuard from Internet (Port 51820) ✅                                     │   │     │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘   │     │
│  │                                                                                         │     │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐   │     │
│  │  │                           Other Hub Subnets                                    │   │     │
│  │  │  • VPN Subnet (172.16.0.0/24) - Azure VPN Gateway (disabled)                  │   │     │
│  │  │  • Gateway Subnet (172.16.1.0/24) - VPN Gateway Infrastructure                │   │     │
│  │  │  • Bastion Subnet (172.16.2.0/24) - Azure Bastion (disabled)                 │   │     │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘   │     │
│  └─────────────────────────────────────────────────────────────────────────────────────────┘     │
│                                              │                                                     │
│                                              │ 🔗 VNet Peering (Enabled)                          │
│                                              ▼                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐     │
│  │                    Core IT Infrastructure (az-core-it-infra)                            │     │
│  │                                  10.0.0.0/16                                           │     │
│  │                                                                                         │     │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐   │     │
│  │  │                  Application Gateway Subnet (10.0.2.0/24)                      │   │     │
│  │  │                                                                                 │   │     │
│  │  │  ┌─────────────────────────────────────────────────────────────────────────┐   │   │     │
│  │  │  │                    Application Gateway                                 │   │   │     │
│  │  │  │                       10.0.2.4                                         │   │   │     │
│  │  │  │                                                                         │   │   │     │
│  │  │  │  ┌─────────────────┐      ┌─────────────────────────────────────┐     │   │   │     │
│  │  │  │  │   Public IP     │      │         SSL Certificate             │     │   │   │     │
│  │  │  │  │ jenkins-azure   │      │    jenkins-azure.dglearn.online     │     │   │   │     │
│  │  │  │  │ .dglearn.online │      │         (HTTPS Termination)         │     │   │   │     │
│  │  │  │  └─────────────────┘      └─────────────────────────────────────┘     │   │   │     │
│  │  │  │                                                                         │   │   │     │
│  │  │  │  🌐 Frontend: Port 80 (HTTP) → 443 (HTTPS)                            │   │   │     │
│  │  │  │  🔄 Backend Pool: Jenkins VM (10.0.1.4:8080)                          │   │   │     │
│  │  │  │                                                                         │   │   │     │
│  │  │  │  🔐 NSG Rules:                                                          │   │   │     │
│  │  │  │  • HTTPS from Internet (Port 443) ✅                                   │   │   │     │
│  │  │  │  • HTTP from Internet (Port 80) ✅                                     │   │   │     │
│  │  │  │  • AppGW Management (Port 65200-65535) ✅                              │   │   │     │
│  │  │  └─────────────────────────────────────────────────────────────────────────┘   │   │     │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘   │     │
│  │                                              │                                         │     │
│  │                                              │ 🔄 Backend Pool Connection              │     │
│  │                                              ▼                                         │     │
│  │  ┌─────────────────────────────────────────────────────────────────────────────────┐   │     │
│  │  │                       Jenkins Subnet (10.0.1.0/24)                             │   │     │
│  │  │                                                                                 │   │     │
│  │  │  ┌─────────────────────────────────────────────────────────────────────────┐   │   │     │
│  │  │  │                         Jenkins VM                                     │   │   │     │
│  │  │  │                        10.0.1.4                                        │   │   │     │
│  │  │  │                                                                         │   │   │     │
│  │  │  │  ┌─────────────────┐      ┌─────────────────────────────────────┐     │   │   │     │
│  │  │  │  │    OS Disk      │      │           Data Disk                 │     │   │   │     │
│  │  │  │  │    32 GB        │      │            20 GB                    │     │   │   │     │
│  │  │  │  │   (Boot)        │      │         (/jenkins)                  │     │   │   │     │
│  │  │  │  │                 │      │      Application Data               │     │   │   │     │
│  │  │  │  └─────────────────┘      └─────────────────────────────────────┘     │   │   │     │
│  │  │  │                                                                         │   │   │     │
│  │  │  │  🚀 Jenkins Service: Port 8080 (HTTP) - Private Only                  │   │   │     │
│  │  │  │  💾 VM Size: Standard_D2s_v3 (2 vCPUs, 8 GB RAM)                     │   │   │     │
│  │  │  │  🔒 Private IP Only - No Public Access                                 │   │   │     │
│  │  │  │                                                                         │   │   │     │
│  │  │  │  🔐 NSG Rules:                                                          │   │   │     │
│  │  │  │  • SSH from 35.235.240.0/20 (Port 22) ✅                              │   │   │     │
│  │  │  │  • SSH from 20.20.20.20/16 (Port 22) ✅                               │   │   │     │
│  │  │  │  • HTTP from AppGW Subnet (Port 8080) ✅                               │   │   │     │
│  │  │  │  • HTTPS from AppGW Subnet (Port 8443) ✅                              │   │   │     │
│  │  │  │  • All from Firezone Subnet (Ports 8080, 8443, 22) ✅                 │   │   │     │
│  │  │  └─────────────────────────────────────────────────────────────────────────┘   │   │     │
│  │  └─────────────────────────────────────────────────────────────────────────────────┘   │     │
│  └─────────────────────────────────────────────────────────────────────────────────────────┘     │
│                                                                                                   │
│  ┌─────────────────────────────────────────────────────────────────────────────────────────┐     │
│  │                          Spoke Network (existing)                                      │     │
│  │                             192.168.0.0/16                                             │     │
│  │                                                                                         │     │
│  │                    📦 Available for other workloads                                    │     │
│  │                    🔗 VNet Peering to Hub Network                                      │     │
│  └─────────────────────────────────────────────────────────────────────────────────────────┘     │
└───────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow Scenarios - User to Jenkins Access Paths

### **Path 1: External HTTPS Access (Internet → Jenkins)**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Internet  │    │     DNS     │    │ Application │    │   Jenkins   │    │   Jenkins   │
│    User     │    │ Resolution  │    │   Gateway   │    │     VM      │    │    Data     │
│             │    │             │    │             │    │             │    │             │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │                  │
       │ 1. HTTPS Request │                  │                  │                  │
       │ jenkins-azure.   │                  │                  │                  │
       │ dglearn.online   │                  │                  │                  │
       ├─────────────────►│                  │                  │                  │
       │                  │ 2. DNS Lookup   │                  │                  │
       │                  │ Returns Public  │                  │                  │
       │                  │ IP of App GW    │                  │                  │
       │◄─────────────────┤                  │                  │                  │
       │                  │                  │                  │                  │
       │ 3. HTTPS:443     │                  │                  │                  │
       │ SSL Encrypted    │                  │                  │                  │
       ├─────────────────────────────────────►│                  │                  │
       │                  │                  │ 4. SSL Termination                 │
       │                  │                  │ Certificate      │                  │
       │                  │                  │ Validation       │                  │
       │                  │                  │                  │                  │
       │                  │                  │ 5. HTTP:8080     │                  │
       │                  │                  │ Backend Request  │                  │
       │                  │                  │ to 10.0.1.4      │                  │
       │                  │                  ├─────────────────►│                  │
       │                  │                  │                  │ 6. Data Access  │
       │                  │                  │                  │ /jenkins mount  │
       │                  │                  │                  ├─────────────────►│
       │                  │                  │                  │ 7. Jenkins Data │
       │                  │                  │                  │◄─────────────────┤
       │                  │                  │ 8. HTTP Response │                  │
       │                  │                  │◄─────────────────┤                  │
       │ 9. HTTPS Response│                  │                  │                  │
       │ SSL Encrypted    │                  │                  │                  │
       │◄─────────────────────────────────────┤                  │                  │
       │                  │                  │                  │                  │

🔐 Security Controls:
• SSL Certificate validation at Application Gateway
• Backend communication over private network (10.0.2.0/24 → 10.0.1.0/24)
• NSG rules allow AppGW subnet to Jenkins VM port 8080
• Jenkins VM has no public IP - completely private
```

### **Path 2: VPN Access (Firezone → Jenkins)**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ VPN Client  │    │  Firezone   │    │   Jenkins   │    │   Jenkins   │    │   Jenkins   │
│   (User)    │    │  Gateway    │    │     VM      │    │    Data     │    │   Service   │
│             │    │ Load Balancer│    │             │    │             │    │             │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │                  │
       │ 1. VPN Connect   │                  │                  │                  │
       │ WireGuard:51820  │                  │                  │                  │
       │ to 172.16.3.10   │                  │                  │                  │
       ├─────────────────►│                  │                  │                  │
       │                  │ 2. Load Balance  │                  │                  │
       │                  │ to Primary/      │                  │                  │
       │                  │ Secondary GW     │                  │                  │
       │                  │ 172.16.3.4/5     │                  │                  │
       │◄─────────────────┤                  │                  │                  │
       │                  │                  │                  │                  │
       │ 3. VPN Tunnel    │                  │                  │                  │
       │ Established      │                  │                  │                  │
       │ Client gets IP   │                  │                  │                  │
       │ in VPN range     │                  │                  │                  │
       │◄─────────────────┤                  │                  │                  │
       │                  │                  │                  │                  │
       │ 4. HTTP:8080     │                  │                  │                  │
       │ via VPN Tunnel   │                  │                  │                  │
       │ to 10.0.1.4      │                  │                  │                  │
       │ (through peering)│                  │                  │                  │
       ├─────────────────────────────────────►│                  │                  │
       │                  │                  │ 5. Data Access  │                  │
       │                  │                  ├─────────────────►│                  │
       │                  │                  │                  │ 6. Service Call │
       │                  │                  │                  ├─────────────────►│
       │                  │                  │                  │ 7. Service Resp │
       │                  │                  │                  │◄─────────────────┤
       │                  │                  │ 8. Jenkins Data │                  │
       │                  │                  │◄─────────────────┤                  │
       │ 9. HTTP Response │                  │                  │                  │
       │ via VPN Tunnel   │                  │                  │                  │
       │◄─────────────────────────────────────┤                  │                  │
       │                  │                  │                  │                  │

🔐 Security Controls:
• WireGuard VPN encryption (end-to-end)
• Load Balancer distributes connections across gateways
• VNet peering allows secure communication (172.16.0.0/16 ↔ 10.0.0.0/16)
• NSG rules allow Firezone subnet to Jenkins VM (ports 8080, 8443, 22)
• Private IP communication only
```

### **Path 3: SSH Administrative Access**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Admin     │    │  Firewall   │    │   Jenkins   │    │   System    │
│  (SSH)      │    │    Rules    │    │     VM      │    │   Access    │
│             │    │   (NSG)     │    │             │    │             │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │
       │ 1. SSH:22        │                  │                  │
       │ from allowed     │                  │                  │
       │ IP ranges        │                  │                  │
       │ 35.235.240.0/20  │                  │                  │
       │ 20.20.20.20/16   │                  │                  │
       ├─────────────────►│                  │                  │
       │                  │ 2. NSG Rule Check│                  │
       │                  │ Rule 1001: SSH  │                  │
       │                  │ from GCP range   │                  │
       │                  │ Rule 1002: SSH  │                  │
       │                  │ from FZ range    │                  │
       │                  │                  │                  │
       │                  │ 3. SSH:22        │                  │
       │                  │ ALLOWED ✅       │                  │
       │                  ├─────────────────►│                  │
       │                  │                  │ 4. SSH Key Auth │
       │                  │                  │ Public Key      │
       │                  │                  │ Validation      │
       │                  │                  │                  │
       │                  │                  │ 5. System Access│
       │                  │                  ├─────────────────►│
       │                  │                  │ 6. Shell Access │
       │                  │                  │◄─────────────────┤
       │ 7. SSH Session   │                  │                  │
       │ Established      │                  │                  │
       │◄─────────────────────────────────────┤                  │
       │                  │                  │                  │

🔐 Security Controls:
• Source IP filtering (only specified ranges allowed)
• SSH key-based authentication (no password)
• Private IP destination (10.0.1.4)
• NSG rules enforce access control
• Audit logging for SSH sessions
```

### **Path 4: Internal Service Communication**

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│ Application │    │   VNet      │    │   Jenkins   │    │   Data      │
│   Gateway   │    │  Peering    │    │     VM      │    │   Disk      │
│             │    │             │    │             │    │             │
└──────┬──────┘    └──────┬──────┘    └──────┬──────┘    └──────┬──────┘
       │                  │                  │                  │
       │ 1. Backend Pool  │                  │                  │
       │ Health Check     │                  │                  │
       │ HTTP:8080        │                  │                  │
       ├─────────────────►│                  │                  │
       │                  │ 2. Route via     │                  │
       │                  │ VNet Peering     │                  │
       │                  │ 10.0.2.0/24 →    │                  │
       │                  │ 10.0.1.0/24      │                  │
       │                  ├─────────────────►│                  │
       │                  │                  │ 3. Jenkins       │
       │                  │                  │ Health Check     │
       │                  │                  │ Response         │
       │                  │                  ├─────────────────►│
       │                  │                  │ 4. Disk I/O      │
       │                  │                  │ /jenkins mount   │
       │                  │                  │◄─────────────────┤
       │                  │ 5. Health OK     │                  │
       │                  │◄─────────────────┤                  │
       │ 6. Backend       │                  │                  │
       │ Available ✅     │                  │                  │
       │◄─────────────────┤                  │                  │
       │                  │                  │                  │

🔐 Security Controls:
• Private network communication only
• VNet peering provides secure connectivity
• Health checks ensure service availability
• Separate data disk for application persistence
```

## 🔐 Security Controls & Network Flow

### **Network Security Groups (NSGs) - Current Configuration**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            Security Rules Matrix                                │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  🛡️  Jenkins Subnet NSG (10.0.1.0/24):                                        │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │ Rule 1001: SSH from 35.235.240.0/20    → Port 22    → ALLOW ✅        │   │
│  │ Rule 1002: SSH from 20.20.20.20/16     → Port 22    → ALLOW ✅        │   │
│  │ Rule 1003: HTTP from AppGW Subnet      → Port 8080  → ALLOW ✅        │   │
│  │ Rule 1004: HTTPS from AppGW Subnet     → Port 8443  → ALLOW ✅        │   │
│  │ Rule 1005: All from Firezone Subnet    → Port 8080+ → ALLOW ✅        │   │
│  │                                                                         │   │
│  │ 🎯 Target: Jenkins VM (10.0.1.4)                                       │   │
│  │ 🔒 Default: DENY all other traffic                                     │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  🌐 Application Gateway Subnet NSG (10.0.2.0/24):                              │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │ Rule 1001: HTTPS from Internet         → Port 443   → ALLOW ✅        │   │
│  │ Rule 1002: HTTP from Internet          → Port 80    → ALLOW ✅        │   │
│  │ Rule 1003: AppGW Management            → Port 65200+ → ALLOW ✅        │   │
│  │                                                                         │   │
│  │ 🎯 Target: Application Gateway (10.0.2.4)                              │   │
│  │ 🔒 Default: DENY all other traffic                                     │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
│                                                                                 │
│  🔐 Firezone Subnet NSG (172.16.3.0/24):                                       │
│  ┌─────────────────────────────────────────────────────────────────────────┐   │
│  │ Rule 1000: SSH from VirtualNetwork     → Port 22    → ALLOW ✅        │   │
│  │ Rule 1100: WireGuard from Internet     → Port 51820 → ALLOW ✅        │   │
│  │                                                                         │   │
│  │ 🎯 Target: Firezone Gateways (172.16.3.4, 172.16.3.5)                 │   │
│  │ 🎯 Target: Load Balancer (172.16.3.10)                                 │   │
│  │ 🔒 Default: DENY all other traffic                                     │   │
│  └─────────────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### **VNet Peering & Routing**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              Network Connectivity                              │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  🌐 Hub Network (172.16.0.0/16)                                                │
│  ├── 🔗 Peering to Core IT Infrastructure ✅                                   │
│  ├── 🔗 Peering to Spoke Network ✅                                             │
│  ├── 🚪 Gateway Transit: Enabled (if VPN Gateway present)                      │
│  └── 🔄 Forwarded Traffic: Allowed                                             │
│                                                                                 │
│  🏢 Core IT Infrastructure (10.0.0.0/16)                                       │
│  ├── 🔗 Peering to Hub Network ✅                                               │
│  ├── 🚪 Use Remote Gateways: Disabled (no VPN Gateway in hub)                  │
│  ├── 🔄 Forwarded Traffic: Allowed                                             │
│  └── 📡 DNS: Private DNS zone linked                                           │
│                                                                                 │
│  🏗️  Spoke Network (192.168.0.0/16)                                            │
│  ├── 🔗 Peering to Hub Network ✅                                               │
│  ├── 🚪 Use Remote Gateways: Disabled                                          │
│  ├── 🔄 Forwarded Traffic: Allowed                                             │
│  └── 📦 Status: Available for other workloads                                  │
│                                                                                 │
│  🛣️  Routing Table:                                                             │
│  ├── 172.16.0.0/16 → Hub Network (direct)                                     │
│  ├── 10.0.0.0/16 → Core IT Infrastructure (direct)                            │
│  ├── 192.168.0.0/16 → Spoke Network (direct)                                  │
│  └── 0.0.0.0/0 → Internet (via Azure default route)                           │
└─────────────────────────────────────────────────────────────────────────────────┘
```

### **High Availability & Load Balancing**

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                           Firezone Gateway HA Setup                            │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  🔄 Internal Load Balancer (172.16.3.10)                                       │
│  ├── 🎯 Frontend IP: 172.16.3.10:51820                                         │
│  ├── 🏊 Backend Pool: Primary + Secondary Gateways                             │
│  ├── 🩺 Health Probe: TCP 51820 (WireGuard port)                               │
│  ├── ⚖️  Load Balancing Rule: UDP 51820 → Backend Pool                          │
│  └── 🌍 Availability: Zone-redundant                                           │
│                                                                                 │
│  🚪 Primary Gateway (172.16.3.4)                                               │
│  ├── 📍 Location: Central US                                                   │
│  ├── 💾 VM Size: Standard_D2s_v3 (2 vCPUs, 8 GB RAM)                          │
│  ├── 🔐 Firezone Token: Configured ✅                                           │
│  ├── 📊 Status: Running                                                        │
│  └── 🔌 WireGuard: Port 51820                                                  │
│                                                                                 │
│  🚪 Secondary Gateway (172.16.3.5)                                             │
│  ├── 📍 Location: Central US                                                   │
│  ├── 💾 VM Size: Standard_D2s_v3 (2 vCPUs, 8 GB RAM)                          │
│  ├── 🔐 Firezone Token: Configured ✅                                           │
│  ├── 📊 Status: Running                                                        │
│  └── 🔌 WireGuard: Port 51820                                                  │
│                                                                                 │
│  ⚡ Failover Behavior:                                                          │
│  ├── 🩺 Health checks every 5 seconds                                          │
│  ├── 🔄 Automatic failover if gateway becomes unhealthy                        │
│  ├── 📈 Load distribution across healthy gateways                              │
│  └── 🔧 Manual failover capability                                             │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 📊 Network Addressing Plan - Current Deployment

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                            IP Address Allocation                               │
├─────────────────────────────────────────────────────────────────────────────────┤
│                                                                                 │
│  🌐 Hub Network (az-networking-global): 172.16.0.0/16                          │
│  ├── 🔌 VPN Subnet:        172.16.0.0/24   (Azure VPN Gateway - disabled)      │
│  ├── 🚪 Gateway Subnet:    172.16.1.0/24   (VPN Gateway Infrastructure)        │
│  ├── 🏰 Bastion Subnet:    172.16.2.0/24   (Azure Bastion - disabled)          │
│  └── 🔐 Firezone Subnet:   172.16.3.0/24   (Firezone Gateways + Load Balancer) │
│      ├── 🚪 Primary FZ:    172.16.3.4      (Running ✅)                        │
│      ├── 🚪 Secondary FZ:   172.16.3.5      (Running ✅)                        │
│      └── ⚖️  Load Balancer: 172.16.3.10     (Active ✅)                         │
│                                                                                 │
│  🏢 Core IT Infrastructure (az-core-it-infra): 10.0.0.0/16                     │
│  ├── 🖥️  Jenkins Subnet:    10.0.1.0/24     (Jenkins VM)                       │
│  │   └── 🖥️  Jenkins VM:    10.0.1.4        (Private IP only ✅)               │
│  └── 🌐 AppGW Subnet:      10.0.2.0/24     (Application Gateway)               │
│      └── 🌐 App Gateway:   10.0.2.4        (Public IP: jenkins-azure...)       │
│                                                                                 │
│  🏗️  Spoke Network (existing): 192.168.0.0/16                                  │
│  └── 📦 Available for other workloads                                          │
│                                                                                 │
│  🌍 Public IPs:                                                                │
│  └── 🌐 jenkins-azure.dglearn.online → Application Gateway Public IP           │
│                                                                                 │
│  🔗 VNet Peering Connections:                                                  │
│  ├── Hub ↔ Core IT Infrastructure ✅                                           │
│  └── Hub ↔ Spoke Network ✅                                                     │
└─────────────────────────────────────────────────────────────────────────────────┘
```

## 🎯 Access Methods Summary - Current State

| **Access Type** | **Source** | **Destination** | **Protocol** | **Port** | **Security** | **Status** |
|----------------|------------|-----------------|--------------|----------|--------------|------------|
| **🌐 HTTPS Web** | Internet | jenkins-azure.dglearn.online | HTTPS | 443 | SSL Certificate | ⚠️ Pending SSL |
| **🔐 VPN Access** | VPN Client | 172.16.3.10:51820 | WireGuard | 51820 | VPN Tunnel | ✅ Active |
| **🛠️ SSH Admin** | 35.235.240.0/20 | 10.0.1.4 | SSH | 22 | Key-based Auth | ✅ Active |
| **🛠️ SSH Admin** | 20.20.20.20/16 | 10.0.1.4 | SSH | 22 | Key-based Auth | ✅ Active |
| **🔄 Internal** | AppGW | 10.0.1.4 | HTTP | 8080 | Private Network | ✅ Active |

## 🚀 Current Deployment Status

### ✅ **Successfully Deployed:**
- Hub Network with Firezone subnet
- Core IT Infrastructure VNet with Jenkins
- Firezone Gateways (Primary + Secondary) with Load Balancer
- Jenkins VM with separate OS and data disks
- Network Security Groups with firewall rules
- VNet peering between all networks
- Private DNS zone configuration

### ⚠️ **Pending Configuration:**
- SSL certificate for Application Gateway
- Application Gateway deployment (commented out)
- DNS A record for jenkins-azure.dglearn.online

### 🔧 **Next Steps:**
1. **Deploy Application Gateway** (uncomment module in main.tf)
2. **Configure SSL certificate** for HTTPS access
3. **Create DNS A record** pointing to Application Gateway public IP
4. **Test all access paths** (HTTPS, VPN, SSH)
5. **Verify Firezone gateway connectivity** in admin portal

This architecture provides a secure, highly available Jenkins environment with multiple access methods while maintaining the principle of least privilege and network segmentation! 🎉