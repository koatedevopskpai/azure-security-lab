output "vm_clean_name" { value = azurerm_linux_virtual_machine.clean.name }
output "vm_clean_ip" { value = azurerm_public_ip.clean.ip_address }
output "vm_quarantined_name" { value = azurerm_linux_virtual_machine.quarantined.name }
output "vm_quarantined_ip" { value = azurerm_public_ip.quar.ip_address }
output "normal_nsg_id" { value = azurerm_network_security_group.normal.id }
output "normal_nsg_name" { value = azurerm_network_security_group.normal.name }
output "quarantine_nsg_id" { value = azurerm_network_security_group.quarantine.id }
output "quarantine_nsg_name" { value = azurerm_network_security_group.quarantine.name }
output "subnet_id" { value = azurerm_subnet.main.id }
output "subnet_name" { value = azurerm_subnet.main.name }
output "quarantine_command" {
  value = "az network vnet subnet update --resource-group ${azurerm_resource_group.main.name} --vnet-name ${azurerm_virtual_network.main.name} --name ${azurerm_subnet.main.name} --network-security-group ${azurerm_network_security_group.quarantine.id}"
}
