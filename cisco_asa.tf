# Resource Group
resource "azurerm_resource_group" "rg" {
  name     = "Cisco-Test-VPN-TF-Managed"
  location = "West Europe"
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "vnet01"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# Subnets
resource "azurerm_subnet" "subnet_mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "asa_public_ip_outside" {
  name                = "asa-public-ip-outside"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  domain_name_label   = "ciscovpn-westeu"
}

resource "azurerm_subnet" "subnet_inside" {
  name                 = "inside"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_subnet" "subnet_outside" {
  name                 = "outside"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.3.0/24"]
}

resource "azurerm_subnet" "subnet_dmz" {
  name                 = "dmz"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.4.0/24"]
}

# Define Network Interfaces
resource "azurerm_network_interface" "asa_nic_mgmt" {
  name                = "asa-nic-mgmt"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "mgmt"
    subnet_id                     = azurerm_subnet.subnet_mgmt.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "asa_nic_inside" {
  name                = "asa-nic-inside"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "inside"
    subnet_id                     = azurerm_subnet.subnet_inside.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface" "asa_nic_outside" {
  name                = "asa-nic-outside"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "outside"
    subnet_id                     = azurerm_subnet.subnet_outside.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.asa_public_ip_outside.id
  }
}

resource "azurerm_network_interface" "asa_nic_dmz" {
  name                = "asa-nic-dmz"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "dmz"
    subnet_id                     = azurerm_subnet.subnet_dmz.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Create the Cisco ASA VM
resource "azurerm_virtual_machine" "asa_vm" {
  name                          = "ciscovpn"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  primary_network_interface_id  = azurerm_network_interface.asa_nic_outside.id
  network_interface_ids = [
    azurerm_network_interface.asa_nic_mgmt.id,
    azurerm_network_interface.asa_nic_inside.id,
    azurerm_network_interface.asa_nic_outside.id,
    azurerm_network_interface.asa_nic_dmz.id,
  ]
  vm_size                       = "Standard_D3_v2"

  storage_os_disk {
    name              = "myosdisk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  storage_image_reference {
    publisher = "cisco"
    offer     = "cisco-asav"
    sku       = "asav-azure-byol"
    version   = "latest"
  }

  plan {
    publisher = "cisco"
    product   = "cisco-asav"
    name      = "asav-azure-byol"
  }

  os_profile {
    computer_name  = "ciscoasa"
    admin_username = "azureuser"
    admin_password = var.admin_password
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      key_data = var.ssh_public_key
      path     = "/home/azureuser/.ssh/authorized_keys"
    }
  }

  tags = {
    environment = "Development"
  }
}
