# ------------------------------------------------------------------------------
# SDCI Lab 07 — Data Loss Prevention & Endpoint Security (Azure)
# main.tf
#
# Uses Microsoft Purview for unified data governance and sensitive data discovery.
#
# Pipeline:
#   1. Storage Account stores sample sensitive data (fake PII)
#   2. Purview account registers the Storage Account as a data source
#   3. Purview scan classifies sensitive content
#   4. Data map shows classified assets and sensitivity labels
#
# COST: Purview 60-day free trial; Storage Account minimal (~$0.02/day)
# --------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name = local.rg_name; location = var.location; tags = local.tags
}

# Storage Account — data source for Purview
resource "azurerm_storage_account" "main" {
  name = local.sa_name; resource_group_name = azurerm_resource_group.main.name
  location = azurerm_resource_group.main.location
  account_tier = "Standard"; account_replication_type = "LRS"
  min_tls_version = "TLS1_2"; tags = local.tags
  blob_properties { versioning_enabled = true }
}

resource "azurerm_storage_container" "data" {
  name = "sampledata"
  storage_account_name = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Sample sensitive data files (simulated PII)
resource "azurerm_storage_blob" "customers_csv" {
  name = "data/customers.csv"
  storage_account_name = azurerm_storage_account.main.name
  storage_container_name = azurerm_storage_container.data.name
  type = "Block"
  content_type = "text/csv"
  source_content = <<-EOT
name,email,phone,ssn,cc_number
Alice Smith,alice@example.com,555-0101,123-45-6789,4111-1111-1111-1111
Bob Jones,bob@test.org,555-0102,987-65-4321,5500-0000-0000-0004
Carol Lee,carol@demo.net,555-0103,456-78-9012,3400-0000-0000-0009
EOT
  metadata = { "sensitivity" = "confidential" }
}

# --------------------------------------------------------------------------
# MICROSOFT PURVIEW — unified data governance
# --------------------------------------------------------------------------
resource "azurerm_purview_account" "main" {
  name                = local.purview_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  public_network_enabled = true
  tags                = local.tags

  identity { type = "SystemAssigned" }
}

# Grant Purview access to read the Storage Account
resource "azurerm_role_assignment" "purview_storage" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Storage Blob Data Reader"
  principal_id         = azurerm_purview_account.main.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}

resource "azurerm_role_assignment" "purview_storage_contrib" {
  scope                = azurerm_storage_account.main.id
  role_definition_name = "Reader"
  principal_id         = azurerm_purview_account.main.identity[0].principal_id
  principal_type       = "ServicePrincipal"
}
