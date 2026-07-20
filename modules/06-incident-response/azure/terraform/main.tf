# ------------------------------------------------------------------------------
# SDCI Lab 06 — Incident Response & Containment (Azure)
# main.tf
#
# Key concept: Quarantine a VM by swapping its subnet's NSG to a deny-all NSG.
# Also configure Just-In-Time (JIT) VM access policy via Defender.
#
# Incident Response workflow:
#   1. Detect compromise (Defender alert, Log Analytics, etc.)
#   2. Quarantine: associate deny-all NSG with the VM's subnet
#   3. Investigate via JIT (temporary port opening) or Bastion
#   4. Release: restore normal NSG
#
# COST: ~$0.14/day (B1s VM only; NSGs free)
# --------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name = local.rg_name; location = var.location; tags = local.tags
}

# VNet
resource "azurerm_virtual_network" "main" {
  name = local.vnet_name; location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space = ["10.0.0.0/16"]; tags = local.tags
}

resource "azurerm_subnet" "main" {
  name = local.snet_name; resource_group_name = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.1.0/24"]
}

# --------------------------------------------------------------------------
# NSGs — normal vs quarantine
# --------------------------------------------------------------------------

# Normal NSG — allows SSH
resource "azurerm_network_security_group" "normal" {
  name = local.nsg_normal; location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name; tags = local.tags
}

resource "azurerm_network_security_rule" "normal_allow_ssh" {
  name = "AllowSSH"; priority = 100; direction = "Inbound"; access = "Allow"
  protocol = "Tcp"; source_port_range = "*"; destination_port_range = "22"
  source_address_prefixes = ["*"]; destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.normal.name
}

# Normal NSG — allow outbound
resource "azurerm_network_security_rule" "normal_allow_outbound" {
  name = "AllowOutbound"; priority = 100; direction = "Outbound"; access = "Allow"
  protocol = "Tcp"; source_port_range = "*"; destination_port_range = "*"
  source_address_prefixes = ["*"]; destination_address_prefixes = ["*"]
  resource_group_name = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.normal.name
}

# Quarantine NSG — deny all inbound and outbound
resource "azurerm_network_security_group" "quarantine" {
  name = local.nsg_quarantine; location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name; tags = local.tags
}

# Deny all inbound (catch-all)
resource "azurerm_network_security_rule" "quarantine_deny_inbound" {
  name = "DenyAllInbound"; priority = 4096; direction = "Inbound"; access = "Deny"
  protocol = "*"; source_port_range = "*"; destination_port_range = "*"
  source_address_prefixes = ["*"]; destination_address_prefix = "*"
  resource_group_name = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.quarantine.name
}

# Deny all outbound
resource "azurerm_network_security_rule" "quarantine_deny_outbound" {
  name = "DenyAllOutbound"; priority = 4096; direction = "Outbound"; access = "Deny"
  protocol = "*"; source_port_range = "*"; destination_port_range = "*"
  source_address_prefixes = ["*"]; destination_address_prefixes = ["*"]
  resource_group_name = azurerm_resource_group.main.name
  network_security_group_name = azurerm_network_security_group.quarantine.name
}

# NSG association — clean subnet is associated with normal NSG initially
resource "azurerm_subnet_network_security_group_association" "main" {
  subnet_id = azurerm_subnet.main.id
  network_security_group_id = azurerm_network_security_group.normal.id
}

# --------------------------------------------------------------------------
# VMs — clean vs pre-quarantined
# --------------------------------------------------------------------------
resource "azurerm_public_ip" "clean" {
  name = "${var.prefix}-pip-clean"; location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method = "Static"; sku = "Standard"; tags = local.tags
}

resource "azurerm_network_interface" "clean" {
  name = "${var.prefix}-nic-clean"; location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name; tags = local.tags
  ip_configuration {
    name = "ipconfig1"; subnet_id = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"; public_ip_address_id = azurerm_public_ip.clean.id
  }
}

resource "azurerm_public_ip" "quar" {
  name = "${var.prefix}-pip-quar"; location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method = "Static"; sku = "Standard"; tags = local.tags
}

resource "azurerm_network_interface" "quar" {
  name = "${var.prefix}-nic-quar"; location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name; tags = local.tags
  ip_configuration {
    name = "ipconfig1"; subnet_id = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"; public_ip_address_id = azurerm_public_ip.quar.id
  }
}

resource "azurerm_linux_virtual_machine" "clean" {
  name = local.vm_clean; location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size = "Standard_B1s"; admin_username = "sdciadmin"
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.clean.id]; tags = local.tags
  admin_ssh_key {
    username = "sdciadmin"; public_key = file("~/.ssh/id_rsa.pub")
  }
  source_image_reference {
    publisher = "Canonical"; offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts-gen2"; version = "latest"
  }
  os_disk { caching = "ReadWrite"; storage_account_type = "Standard_LRS"; disk_size_gb = 30 }
}

resource "azurerm_linux_virtual_machine" "quarantined" {
  name = local.vm_quar; location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size = "Standard_B1s"; admin_username = "sdciadmin"
  disable_password_authentication = true
  network_interface_ids = [azurerm_network_interface.quar.id]; tags = local.tags
  admin_ssh_key {
    username = "sdciadmin"; public_key = file("~/.ssh/id_rsa.pub")
  }
  source_image_reference {
    publisher = "Canonical"; offer = "0001-com-ubuntu-server-jammy"
    sku = "22_04-lts-gen2"; version = "latest"
  }
  os_disk { caching = "ReadWrite"; storage_account_type = "Standard_LRS"; disk_size_gb = 30 }
}

