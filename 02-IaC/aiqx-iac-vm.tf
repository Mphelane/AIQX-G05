# add Azure provider and the subscriptionID
provider "azurerm" {
  features {}

  subscription_id = "xxxxxxxxxxxxxxxxxxxx" ## please add you Azure SubscriptionID here
}

# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "aiqx-rg"
  location = "South Africa North"
}

# VNet Configuration
resource "azurerm_virtual_network" "vnet" {
  name                = "aiqx-vnet"
  address_space       = ["10.0.0.0/16"]  # Large address space
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnet
resource "azurerm_subnet" "subnet" {
  name                 = "aiqx-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# NSG - inbound/outbound traffic
resource "azurerm_network_security_group" "nsg" {
  name                = "aiqx-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Allow SSH on port 22 from anywhere
  security_rule {
    name                       = "AllowSSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Public IP Address
resource "azurerm_public_ip" "public_ip" {
  name                = "aiqx-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method   = "Dynamic" 
  sku                 = "Basic"    # Basic SKU supports Dynamic IPs
}

# NIC - connects VM to the VNet and public IP
resource "azurerm_network_interface" "nic" {
  name                = "aiqx-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Applies the security rules to all resources in the subnet (associate NSG with subnet)
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

# CentOS VM
resource "azurerm_linux_virtual_machine" "vm" {
  name                = "aiqx-centos-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  # Lowest tier VM for minimal cost
  size                = "Standard_B1s"

  # admin username
  admin_username      = "aiqx-admin"
  admin_password      = "P@ssword123!"

  disable_password_authentication = false # password login

  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  # OS disk configuration
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "aiqx-centos-os-disk"
  }

  # CentOS 7.9 image from Azure Marketplace
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }
}
