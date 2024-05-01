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

# Define Subnets
resource "azurerm_subnet" "subnet_mgmt" {
  name                 = "mgmt"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
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

# Public IP for Load Balancer
resource "azurerm_public_ip" "asa_public_ip_outside" {
  name                = "asa-public-ip-outside"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  domain_name_label   = "ciscovpn-westeu"
}

# Availability Set
resource "azurerm_availability_set" "asa_av_set" {
  name                        = "asa-availability-set"
  location                    = azurerm_resource_group.rg.location
  resource_group_name         = azurerm_resource_group.rg.name
  platform_fault_domain_count = 2
  platform_update_domain_count= 2
  managed                     = true
}

# Network Interfaces
resource "azurerm_network_interface" "asa_nic_mgmt" {
  count               = var.vm_count
  name                = "asa-nic-mgmt-vm${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "mgmt-config-${count.index}"
    subnet_id                     = azurerm_subnet.subnet_mgmt.id
    private_ip_address_allocation = "Dynamic"
    primary                       = false
  }
}

resource "azurerm_network_interface" "asa_nic_inside" {
  count               = var.vm_count
  name                = "asa-nic-inside-vm${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "inside-config-${count.index}"
    subnet_id                     = azurerm_subnet.subnet_inside.id
    private_ip_address_allocation = "Dynamic"
    primary                       = false
  }
}

resource "azurerm_network_interface" "asa_nic_outside" {
  count               = var.vm_count
  name                = "asa-nic-outside-vm${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "outside-config-${count.index}"
    subnet_id                     = azurerm_subnet.subnet_outside.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.asa_public_ip_outside.id
    primary                       = true
  }
}

resource "azurerm_network_interface" "asa_nic_dmz" {
  count               = var.vm_count
  name                = "asa-nic-dmz-vm${count.index}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "dmz-config-${count.index}"
    subnet_id                     = azurerm_subnet.subnet_dmz.id
    private_ip_address_allocation = "Dynamic"
    primary                       = false
  }
}

# Virtual Machines
resource "azurerm_virtual_machine" "asa_vm" {
  count                         = var.vm_count
  name                          = "ciscovpn-${count.index}"
  location                      = azurerm_resource_group.rg.location
  resource_group_name           = azurerm_resource_group.rg.name
  network_interface_ids         = [
    azurerm_network_interface.asa_nic_mgmt[count.index].id,
    azurerm_network_interface.asa_nic_inside[count.index].id,
    azurerm_network_interface.asa_nic_outside[count.index].id,
    azurerm_network_interface.asa_nic_dmz[count.index].id
  ]
  vm_size                       = "Standard_A4_v2"
  availability_set_id           = azurerm_availability_set.asa_av_set.id
  delete_os_disk_on_termination = true

  storage_os_disk {
    name              = "myosdisk-${count.index}"
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

  os_profile {
    computer_name  = "ciscoasa-${count.index}"
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
