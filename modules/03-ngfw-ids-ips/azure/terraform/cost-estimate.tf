# ==============================================================================
# Cost estimate — SDCI Lab 03 (Azure)
#
# RESOURCE                         ESTIMATED DAILY COST    NOTES
# -------------------------------  ----------------------  ----------------------------
# Resource Group                   $0.00                  Free
# VNet + Subnets                   $0.00                  Free
# Application Security Groups      $0.00                  Free
# Network Security Groups + Rules  $0.00                  Free
# Azure Front Door (Standard)      ~$0.89/day             $35/mo approx
# WAF Policy                       $0.00                  Included with Front Door
# Public IP (Standard, static)     ~$0.00                 $0.005/hr = $0.12/day (first 5 free)
# VM Standard_B1s                  ~$0.14/day             $0.006/hr; 750 hrs/mo free tier
# Managed Disk (Standard_LRS 30GB) ~$0.04/day            $0.05/GB/mo
# Defender for Cloud (CSPM)        $0.00                  Foundational tier free
# ---------------------------------------------------------------
# TOTAL (best case)                ~$0.00/day             If free tier + credits apply
# TOTAL (worst case)               ~$1.07/day             Minimal free tier remaining
# ==============================================================================
