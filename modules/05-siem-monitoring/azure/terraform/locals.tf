locals {
  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    AzureRegion  = var.location
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }
  tags = merge(var.extra_tags, local.mandatory_tags)

  rg_name       = "${var.prefix}-rg"
  vnet_name     = "${var.prefix}-vnet"
  snet_name     = "${var.prefix}-snet"
  nsg_name      = "${var.prefix}-nsg"
  pip_name      = "${var.prefix}-pip"
  nic_name      = "${var.prefix}-nic"
  vm_name       = "${var.prefix}-vm"
  la_name       = "${var.prefix}-law"
  action_group  = "${var.prefix}-ag"
  alert_name    = "${var.prefix}-high-ssh"
  query_name    = "${var.prefix}-ssh-query"
}
