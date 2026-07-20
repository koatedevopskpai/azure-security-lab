locals {
  name_prefix = "sdci-01-azure"

  mandatory_tags = {
    CostCenter   = "SDCI-Lab"
    Environment  = "Training"
    Module       = var.module_name
    Cloud        = "azure"
    Creator      = var.creator
    DestroyAfter = var.destroy_after
  }

  tags = merge(var.extra_tags, local.mandatory_tags)

  rg_name            = "rg-${local.name_prefix}"
  vnet_name          = "${local.name_prefix}-vnet"
  nsg_access         = "${local.name_prefix}-nsg-access"
  nsg_distribution   = "${local.name_prefix}-nsg-distribution"
  nsg_core           = "${local.name_prefix}-nsg-core"
  rt_private         = "${local.name_prefix}-rt-private"
  nat_name           = "${local.name_prefix}-nat"
  nat_pip            = "${local.name_prefix}-nat-pip"
  bastion_name       = "${local.name_prefix}-bastion"
  bastion_nic        = "${local.name_prefix}-bastion-nic"
  bastion_pip        = "${local.name_prefix}-bastion-pip"

  # Generated admin password if not provided
  admin_password = var.admin_password != "" ? var.admin_password : random_password.admin.result
}
