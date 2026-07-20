resource "null_resource" "cost_estimate" {
  triggers = {
    enable_nat    = var.enable_nat
    enable_bastion = var.enable_bastion
  }

  provisioner "local-exec" {
    command = <<-EOT
      Write-Host @"
      ╔══════════════════════════════════════════════════════════════╗
      ║  COST ESTIMATE — SDCI Lab 01: VNet Segmentation (Azure)    ║
      ╠══════════════════════════════════════════════════════════════╣
      ║ Resource                       Qty    Rate/Day    Free Tier ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║ VNet                            1     $0.00       Yes       ║
      ║ Subnets (3)                     3     $0.00       Yes       ║
      ║ NSGs (3)                        3     $0.00       Yes       ║
      ║ NAT Gateway                     1     $1.08       No  ***   ║
      ║ Public IP (NAT)                 1     $0.00       Yes*      ║
      ║ B1s bastion VM                  1     $0.00       Yes*      ║
      ║ Public IP (bastion)             1     $0.00       Yes*      ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║  TOTAL                          -     $1.08                 ║
      ║                                                              ║
      ║  *** NAT Gateway is NOT free (~$32/month if left running).   ║
      ║  * B1s VM and public IPs free tier eligible (750 hrs/mo).    ║
      ║                                                              ║
      ║  Daily budget cap: $1.00. NAT alone exceeds this if run 24h. ║
      ║  Strategy: single 2-hour session (~$0.09), destroy after.    ║
      ╚══════════════════════════════════════════════════════════════╝
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}
