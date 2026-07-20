# ==============================================================================
# Cost estimate — SDCI Lab 05 (Azure)
#
# RESOURCE                         ESTIMATED DAILY COST    NOTES
# -------------------------------  ----------------------  ----------------------------
# Resource Group + VNet            $0.00                  Free
# Network Security Group           $0.00                  Free
# NSG Diagnostic Logs              ~$0.02                 Minimal data volume
# Log Analytics Workspace          $0.00                  Free tier: 5 GB/month
# Saved KQL Query                  $0.00                  Free
# Log Alert Rule                   $0.00                  Free (1st 100 queries free)
# Action Group                     $0.00                  Free (email notifications)
# Public IP (Standard)             ~$0.00                 $0.005/hr; first 5 free
# VM Standard_B1s                  ~$0.14/day             $0.006/hr
# Managed Disk 30 GB               ~$0.04/day             $0.05/GB/mo
# ---------------------------------------------------------------
# TOTAL                            ~$0.20/day
# ==============================================================================
