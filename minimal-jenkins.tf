# Minimal Jenkins Deployment - Single File Configuration
# This is a simplified, single-file approach to avoid module complexity

terraform {
  required_version = ">= 1.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
}

# Variables
variable "name_prefix" {
  type        = string
  default     = "vijay-"
  description = "Prefix for all resource names"
}

variable "location" {
  type        = string
  default     = "East US"
  description = "Azure region for deployment"
}

variable "ssh_public_key" {
  type        = string
  description = "SSH public key for VM access"
  default     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC... your-public-key-here"
}

variable "jenkins_vm_size" {
  type        = string
  default     = "Standard_A1"
  description = "Size of the Jenkins VM"
}

# Resource Group
resource "azurerm_resource_group" "jenkins" {
  name     = "${var.name_prefix}jenkins-rg"
  location = var.location
  
  tags = {
    Environment = "demo"
    Project     = "jenkins"
    ManagedBy   = "terraform"
  }
}

# Virtual Network
resource "azurerm_virtual_network" "jenkins" {
  name                = "${var.name_prefix}jenkins-vnet"
  address_space       = ["192.168.0.0/16"]
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name
  
  tags = {
    Environment = "demo"
    Project     = "jenkins"
  }
}

# Subnet
resource "azurerm_subnet" "jenkins" {
  name                 = "jenkins-subnet"
  resource_group_name  = azurerm_resource_group.jenkins.name
  virtual_network_name = azurerm_virtual_network.jenkins.name
  address_prefixes     = ["192.168.1.0/24"]
}

# Network Security Group
resource "azurerm_network_security_group" "jenkins" {
  name                = "${var.name_prefix}jenkins-nsg"
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name

  # Allow SSH
  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow Jenkins
  security_rule {
    name                       = "Jenkins"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "8080"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  
  tags = {
    Environment = "demo"
    Project     = "jenkins"
  }
}

# Associate NSG with Subnet
resource "azurerm_subnet_network_security_group_association" "jenkins" {
  subnet_id                 = azurerm_subnet.jenkins.id
  network_security_group_id = azurerm_network_security_group.jenkins.id
}

# Network Interface
resource "azurerm_network_interface" "jenkins" {
  name                = "${var.name_prefix}jenkins-nic"
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.jenkins.id
    private_ip_address_allocation = "Dynamic"
  }
  
  tags = {
    Environment = "demo"
    Project     = "jenkins"
  }
}

# Data Disk
resource "azurerm_managed_disk" "jenkins" {
  name                 = "${var.name_prefix}jenkins-data"
  location             = azurerm_resource_group.jenkins.location
  resource_group_name  = azurerm_resource_group.jenkins.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 20
  
  tags = {
    Environment = "demo"
    Project     = "jenkins"
  }
}

# Virtual Machine
resource "azurerm_linux_virtual_machine" "jenkins" {
  name                = "${var.name_prefix}jenkins-vm"
  location            = azurerm_resource_group.jenkins.location
  resource_group_name = azurerm_resource_group.jenkins.name
  size                = var.jenkins_vm_size
  admin_username      = "azureuser"

  disable_password_authentication = true

  network_interface_ids = [
    azurerm_network_interface.jenkins.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  # Jenkins installation script
  custom_data = base64encode(<<-EOF
    #!/bin/bash
    
    # Update system
    apt-get update
    
    # Install Java
    apt-get install -y openjdk-11-jdk
    
    # Install Jenkins
    wget -q -O - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -
    sh -c 'echo deb https://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
    apt-get update
    apt-get install -y jenkins
    
    # Format and mount data disk
    mkfs.ext4 /dev/sdc
    mkdir -p /jenkins
    mount /dev/sdc /jenkins
    echo '/dev/sdc /jenkins ext4 defaults 0 0' >> /etc/fstab
    
    # Set Jenkins home
    chown -R jenkins:jenkins /jenkins
    sed -i 's|JENKINS_HOME=.*|JENKINS_HOME=/jenkins|' /etc/default/jenkins
    
    # Start Jenkins
    systemctl enable jenkins
    systemctl start jenkins
    
    # Create startup log
    echo "Jenkins installation completed at $(date)" > /var/log/jenkins-startup.log
  EOF
  )
  
  tags = {
    Environment = "demo"
    Project     = "jenkins"
  }
}

# Attach Data Disk
resource "azurerm_virtual_machine_data_disk_attachment" "jenkins" {
  managed_disk_id    = azurerm_managed_disk.jenkins.id
  virtual_machine_id = azurerm_linux_virtual_machine.jenkins.id
  lun                = "0"
  caching            = "ReadWrite"
}

# Outputs
output "jenkins_vm_info" {
  description = "Jenkins VM information"
  value = {
    name               = azurerm_linux_virtual_machine.jenkins.name
    private_ip_address = azurerm_network_interface.jenkins.private_ip_address
    jenkins_url        = "http://${azurerm_network_interface.jenkins.private_ip_address}:8080"
    ssh_command        = "ssh azureuser@${azurerm_network_interface.jenkins.private_ip_address}"
  }
}

output "resource_group" {
  description = "Resource group information"
  value = {
    name     = azurerm_resource_group.jenkins.name
    location = azurerm_resource_group.jenkins.location
  }
}