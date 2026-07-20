resource "null_resource" "cost_estimate" {
  provisioner "local-exec" {
    command = <<-EOT
      Write-Host @"
      ╔══════════════════════════════════════════════════════════════╗
      ║  COST ESTIMATE — SDCI Lab 02: Remote Access VPN (Azure)    ║
      ╠══════════════════════════════════════════════════════════════╣
      ║ Resource                       Qty    Rate/Day    Free Tier ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║ VNet + subnets (2)             1     $0.00       Yes       ║
      ║ VPN Gateway (VpnGw1)           1     $0.72       No  ***   ║
      ║ Public IP                      1     $0.00       Yes*      ║
      ║ B1s workload VM                1     $0.00       Yes*      ║
      ║ NSG                             1     $0.00       Yes       ║
      ║ ──────────────────────────────────────────────────────────── ║
      ║  TOTAL                          -     $0.72                 ║
      ║                                                              ║
      ║  *** VPN Gateway is NOT free tier. ~$0.03/hr.               ║
      ║  * B1s VM free tier: 750 hrs/month.                         ║
      ║                                                              ║
      ║  Daily budget cap: $1.00. 2-hr session = $0.06.             ║
      ║  DESTROY IMMEDIATELY AFTER USE.                              ║
      ╚══════════════════════════════════════════════════════════════╝
      "@
    EOT
    interpreter = ["PowerShell", "-Command"]
  }
}
