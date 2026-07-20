# ------------------------------------------------------------------------------
# SDCI Lab 04 — Zero Trust & Identity Access Management (Azure)
# main.tf
#
# Key concepts demonstrated:
#   1. Workload identity — Managed Identity bound to a VM
#   2. Least-privilege RBAC — Custom role with minimal permissions
#   3. Scope-based role assignment — Role bound to specific Storage Account
#   4. Policy-as-Code — All RBAC defined in Terraform
#
# ARCHITECTURE:
#   Developer → SSH/Portal → VM → Managed Identity → reads Storage Account
# COST: Managed Identity free, B1s VM ~$0.14/day, RBAC/roles free
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------------
# Resource group
# --------------------------------------------------------------------------
resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# --------------------------------------------------------------------------
# Virtual network and subnet
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

# --------------------------------------------------------------------------
# NSG — allows SSH (pre-Zero Trust; see docs for JIT/Bastion alternatives)
# --------------------------------------------------------------------------
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

# --------------------------------------------------------------------------
# STORAGE ACCOUNT — resource for RBAC demonstration
# --------------------------------------------------------------------------
resource "random_id" "suffix" {
  byte_length = 4
}

resource "azurerm_storage_account" "main" {
  name                     = "${local.sa_basename}${random_id.suffix.hex}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  min_tls_version          = "TLS1_2"
  tags                     = local.tags
}

resource "azurerm_storage_container" "main" {
  name                  = "sdci-lab-data"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# --------------------------------------------------------------------------
# USER-ASSIGNED MANAGED IDENTITY — workload identity for VM
# --------------------------------------------------------------------------
resource "azurerm_user_assigned_identity" "main" {
  name                = local.msi_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tags                = local.tags
}

# --------------------------------------------------------------------------
# CUSTOM RBAC ROLE — least privilege (read-only on Storage Account)
# --------------------------------------------------------------------------
resource "azurerm_role_definition" "main" {
  name        = local.role_def_name
  scope       = azurerm_resource_group.main.id
  description = "Least-privilege role: read Storage Account containers and blobs"

  permissions {
    actions = [
      "Microsoft.Storage/storageAccounts/blobServices/containers/read",
      "Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read",
    ]
    not_actions = []
  }

  assignable_scopes = [
    azurerm_resource_group.main.id,
  ]
}

# --------------------------------------------------------------------------
# ROLE ASSIGNMENT — grants the Managed Identity the custom role
# Scoped to the Storage Account (resource-level scoping)
# --------------------------------------------------------------------------
resource "azurerm_role_assignment" "main" {
  scope                = azurerm_storage_account.main.id
  role_definition_id   = azurerm_role_definition.main.role_definition_resource_id
  principal_id         = azurerm_user_assigned_identity.main.principal_id
  principal_type       = "ServicePrincipal"
}

# --------------------------------------------------------------------------
# VM — with User-Assigned Managed Identity
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

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.main.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    apt-get update
    apt-get install -y jq curl
  EOF
  )
}
