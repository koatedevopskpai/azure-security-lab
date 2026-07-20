output "resource_group_name" { value = azurerm_resource_group.main.name }
output "vm_name" { value = azurerm_linux_virtual_machine.main.name }
output "vm_public_ip" { value = azurerm_public_ip.main.ip_address }
output "managed_identity_name" { value = azurerm_user_assigned_identity.main.name }
output "managed_identity_client_id" { value = azurerm_user_assigned_identity.main.client_id }
output "managed_identity_principal_id" { value = azurerm_user_assigned_identity.main.principal_id }
output "custom_role_name" { value = azurerm_role_definition.main.name }
output "storage_account_name" { value = azurerm_storage_account.main.name }
output "ssh_command" {
  value = "ssh sdciadmin@${azurerm_public_ip.main.ip_address}"
}
