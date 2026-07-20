# ------------------------------------------------------------------------------
# SDCI Lab 05 — SIEM, Monitoring & UEBA (Azure)
# main.tf
#
# Key concepts demonstrated:
#   1. Log Analytics Workspace — centralized log storage
#   2. Diagnostic settings — forward resource logs to Log Analytics
#   3. KQL saved queries — reusable security analytics
#   4. Log Alert Rules — proactive notification on suspicious patterns
#   5. Action Groups — notification routing
#
# ARCHITECTURE:
#   Resource Logs → Log Analytics → KQL Query → Alert Rule → Action Group
# COST: Log Analytics free tier (5 GB/mo), alerts/action groups free
# --------------------------------------------------------------------------

# --------------------------------------------------------------------------
# Resource group
# --------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# --------------------------------------------------------------------------
# LOG ANALYTICS WORKSPACE — central SIEM log repository
# Free tier: 5 GB/month data ingestion
# --------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "main" {
  name                = local.la_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = local.tags
}

# --------------------------------------------------------------------------
# VNet + Subnet + NSG
# --------------------------------------------------------------------------
resource "azurerm_virtual_network" "main" {
  name                = local.vnet_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
  tags                = local.tags
}

resource "azurerm_subnet" "main" {
  name                 = local.snet_name
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "main" {
  name                = local.nsg_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "AllowSSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefixes     = ["*"]
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.main.name
}

resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id                 = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

# NSG diagnostic settings — send flow event logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "nsg" {
  name                       = "${local.nsg_name}-diag"
  target_resource_id         = azurerm_network_security_group.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  enabled_log {
    category = "NetworkSecurityGroupEvent"
  }
  enabled_log {
    category = "NetworkSecurityGroupRuleCounter"
  }
  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# --------------------------------------------------------------------------
# VM — generates baseline activity for the SIEM pipeline
# --------------------------------------------------------------------------
resource "azurerm_public_ip" "main" {
  name                = local.pip_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = local.tags
}

resource "azurerm_network_interface" "main" {
  name                = local.nic_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = local.vm_name
  location                        = azurerm_resource_group.main.location
  resource_group_name             = azurerm_resource_group.main.name
  size                            = "Standard_B1s"
  admin_username                  = "sdciadmin"
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.main.id]
  tags                            = local.tags

  admin_ssh_key {
    username   = "sdciadmin"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  boot_diagnostics {}
}

# VM diagnostic settings — send metrics and logs to Log Analytics
resource "azurerm_monitor_diagnostic_setting" "vm" {
  name                       = "${local.vm_name}-diag"
  target_resource_id         = azurerm_linux_virtual_machine.main.id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# --------------------------------------------------------------------------
# SAVED KQL QUERY — reusable SSH anomaly detection query
# --------------------------------------------------------------------------
resource "azurerm_log_analytics_saved_search" "ssh_query" {
  name                    = local.query_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.main.id
  category                = "SDCI Lab 05"
  display_name            = "SSH Connection Analysis"
  query                   = <<-EOT
    // Detect failed SSH connections from network security group events
    AzureDiagnostics
    | where Category == "NetworkSecurityGroupEvent"
    | where OperationName == "NetworkSecurityGroupFlowEvents"
    | where flow_s contains "I"  // Inbound rules
    | where flowStatus_s == "F"  // Failed/blocked
    | extend
        SourceIP = extract(@"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)", 1, flow_s),
        DestinationPort = extract(@":([0-9]+)$", 1, flow_s)
    | where DestinationPort == "22"
    | project TimeGenerated, SourceIP, DestinationPort, flowStatus_s, flow_s
    | order by TimeGenerated desc
    | limit 100
  EOT
  tags                    = local.tags
}

# --------------------------------------------------------------------------
# ACTION GROUP — notification routing
# --------------------------------------------------------------------------
resource "azurerm_monitor_action_group" "main" {
  name                = local.action_group
  resource_group_name = azurerm_resource_group.main.name
  short_name          = "sdci-siem"
  tags                = local.tags
}

# --------------------------------------------------------------------------
# LOG ALERT RULE — fires when SSH failures exceed threshold in 5 min
# --------------------------------------------------------------------------
resource "azurerm_monitor_scheduled_query_rules_alert" "high_ssh" {
  name                = local.alert_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  action {
    action_group = [azurerm_monitor_action_group.main.id]
  }
  data_source_id = azurerm_log_analytics_workspace.main.id
  description    = "High number of failed SSH connections detected"
  enabled        = true

  query = <<-EOT
    AzureDiagnostics
    | where Category == "NetworkSecurityGroupEvent"
    | where OperationName == "NetworkSecurityGroupFlowEvents"
    | where flow_s contains "I"
    | where flowStatus_s == "F"
    | extend DestinationPort = extract(@":([0-9]+)$", 1, flow_s)
    | where DestinationPort == "22"
    | summarize SSHAttempts = count() by bin(TimeGenerated, 5m)
    | where SSHAttempts > 10
  EOT
  severity    = 2
  frequency   = 5
  time_window = 5
  trigger {
    operator  = "GreaterThan"
    threshold = 0
  }
  tags = local.tags
}
