output "asa_vm_public_ip" {
  value = azurerm_public_ip.asa_public_ip_outside.ip_address
}
