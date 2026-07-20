output "resource_group_name" { value = azurerm_resource_group.main.name }
output "frontdoor_hostname" { value = "${azurerm_frontdoor.main.name}.azurefd.net" }
output "waf_policy_id" { value = azurerm_waf_policy.main.id }
output "vm_web_public_ip" { value = azurerm_public_ip.web.ip_address }
output "web_asg_id" { value = azurerm_application_security_group.web.id }
output "app_asg_id" { value = azurerm_application_security_group.app.id }
output "vnet_id" { value = azurerm_virtual_network.main.id }
