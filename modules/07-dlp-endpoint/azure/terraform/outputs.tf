output "resource_group_name" { value = azurerm_resource_group.main.name }
output "storage_account_name" { value = azurerm_storage_account.main.name }
output "purview_account_name" { value = azurerm_purview_account.main.name }
output "purview_catalog_endpoint" { value = azurerm_purview_account.main.catalog_endpoint }
output "purview_portal_url" { value = "https://${azurerm_purview_account.main.name}.purview.azure.com" }
output "sample_data_blob" { value = "https://${azurerm_storage_account.main.name}.blob.core.windows.net/sampledata/data/customers.csv" }
