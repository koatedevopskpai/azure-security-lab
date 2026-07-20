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

  rg_name    = "${var.prefix}-rg"
  vnet_name  = "${var.prefix}-vnet"
  snet_web   = "${var.prefix}-snet-web"
  snet_app   = "${var.prefix}-snet-app"

  nsg_web    = "${var.prefix}-nsg-web"
  nsg_app    = "${var.prefix}-nsg-app"

  asg_web    = "${var.prefix}-asg-web"
  asg_app    = "${var.prefix}-asg-app"

  fd_name    = "${var.prefix}-fd"
  waf_name   = "${var.prefix}-waf-policy"
  waf_name2  = "${var.prefix}-waf2-policy"

  vm_web     = "${var.prefix}-vm-web"
  vm_app     = "${var.prefix}-vm-app"
  nic_web    = "${var.prefix}-nic-web"
  nic_app    = "${var.prefix}-nic-app"
  pip_web    = "${var.prefix}-pip-web"
  pip_fd     = "${var.prefix}-pip-fd"

  log_analytics = "${var.prefix}-la"
}
