# SDCI Lab 01 — VNet Segmentation (Azure)

**Cisco SDCI 300-745 Domain**: Network segmentation & layered architecture

## Overview

This lab translates the **flat-to-layered network migration** case study into Azure. You'll provision a three-tier VNet with Access, Distribution, and Core subnets, enforce zone-based NSG rules, and verify lateral movement prevention.

## Cost Warning

Azure NAT Gateway costs ~$1.08/day and is **NOT free tier eligible**. Deploy, verify, destroy within 2 hours (~$0.09).

## Files

| File | Purpose |
|------|---------|
| `terraform/` | All Terraform IaC |
| `cleanup.ps1` | Resource destruction |

## Quick Commands

```powershell
cd terraform
terraform init
terraform plan        # Review + cost estimate
terraform apply       # Deploy
terraform destroy     # Clean up
```
