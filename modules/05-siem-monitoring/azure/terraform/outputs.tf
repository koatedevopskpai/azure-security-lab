output "resource_group_name" { value = azurerm_resource_group.main.name }
output "vm_name" { value = azurerm_linux_virtual_machine.main.name }
output "vm_public_ip" { value = azurerm_public_ip.main.ip_address }
output "log_analytics_workspace" { value = azurerm_log_analytics_workspace.main.name }
output "log_analytics_workspace_id" { value = azurerm_log_analytics_workspace.main.workspace_id }
output "saved_query_name" { value = azurerm_log_analytics_saved_search.ssh_query.name }
output "alert_rule_name" { value = azurerm_monitor_scheduled_query_rules_alert.high_ssh.name }
output "log_analytics_url" {
  value = "https://portal.azure.com/#blade/Microsoft_OperationsManagementSuite_Workspace/Logs.ReactView/resourceId/${azurerm_log_analytics_workspace.main.id}"
}
