# ==============================================================================
# Cost estimate — SDCI Lab 04 (Azure)
#
# RESOURCE                         ESTIMATED DAILY COST    NOTES
# -------------------------------  ----------------------  ----------------------------
# VNet + Subnet                    $0.00                  Free
# Network Security Group           $0.00                  Free
# Public IP (Standard, static)     ~$0.00                 $0.005/hr = $0.12/day (5 free)
# VM Standard_B1s                  ~$0.14/day             $0.006/hr; 750 hrs/mo free tier
# Managed Disk (Standard_LRS 30GB) ~$0.04/day            $0.05/GB/mo
# Managed Identity                 $0.00                  Free
# Custom RBAC Role                 $0.00                  Free
# Role Assignment                  $0.00                  Free
# Storage Account Standard_LRS     ~$0.02/day            $0.018/GB/mo minimal usage
# ---------------------------------------------------------------
# TOTAL (best case)                ~$0.00/day             Free tier + credits
# TOTAL (worst case)               ~$0.20/day             No free tier remaining
# ==============================================================================
