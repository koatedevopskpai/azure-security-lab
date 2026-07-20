locals {
  mandatory_tags = {
    CostCenter = "SDCI-Lab"; Environment = "Training"; Module = var.module_name
    AzureRegion = var.location; Creator = var.creator; DestroyAfter = var.destroy_after
  }
  tags = merge(var.extra_tags, local.mandatory_tags)
  rg_name     = "${var.prefix}-rg"
  sa_name     = replace("${var.prefix}sa", "-", "")
  purview_name = replace("${var.prefix}pv", "-", "")
}
