locals {
  name_prefix = "sdci-02-azure"

  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    Cloud        = "azure"
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }

  tags = merge(var.extra_tags, local.mandatory_tags)

  rg_name      = "rg-${local.name_prefix}"
  vnet_name    = "${local.name_prefix}-vnet"
  snet_gw      = "${local.name_prefix}-snet-gw"
  snet_workload = "${local.name_prefix}-snet-workload"
  nsg_workload = "${local.name_prefix}-nsg-workload"
  pip_name     = "${local.name_prefix}-gw-pip"
  gw_name      = "${local.name_prefix}-gw"
  workload_name = "${local.name_prefix}-vm"
}
