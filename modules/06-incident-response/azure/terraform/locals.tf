locals {
  mandatory_tags = {
    CostCenter = "SDCI-Lab"; Environment = "Training"; Module = var.module_name
    AzureRegion = var.location; Creator = var.creator; DestroyAfter = var.destroy_after
  }
  tags = merge(var.extra_tags, local.mandatory_tags)

  rg_name         = "${var.prefix}-rg"
  vnet_name       = "${var.prefix}-vnet"
  snet_name       = "${var.prefix}-snet"
  nsg_normal      = "${var.prefix}-nsg-normal"
  nsg_quarantine  = "${var.prefix}-nsg-quarantine"
  vm_clean        = "${var.prefix}-vm-clean"
  vm_quar         = "${var.prefix}-vm-quarantined"
}
