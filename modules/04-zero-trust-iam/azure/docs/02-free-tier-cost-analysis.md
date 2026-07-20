# SDCI Lab 04 — Azure: Free Tier & Cost Analysis

## Per-Resource Breakdown

| Resource | Pricing Model | Daily Cost | Free Tier |
|----------|--------------|-----------|-----------|
| VNet + Subnet | Free | $0.00 | Always free |
| NSG + Rules | Free | $0.00 | Always free |
| Public IP (Standard, static) | $0.005/hr | ~$0.12 | First 5 free per sub |
| VM Standard_B1s | $0.006/hr | ~$0.14 | 750 hrs/mo (12 months) |
| Managed Disk Standard_LRS 30GB | $0.05/GB/mo | ~$0.04 | — |
| Managed Identity | Free | $0.00 | Always free |
| Custom RBAC Role | Free | $0.00 | Always free |
| Role Assignment | Free | $0.00 | Always free |
| Storage Account Standard_LRS | $0.018/GB/mo | ~$0.02 | — |

## Cost Scenarios

| Scenario | Daily | Monthly |
|----------|-------|---------|
| **Best case** — Free tier + credits | **~$0.00** | ~$0.00 |
| **Worst case** — No free tier | **~$0.20** | ~$6.00 |

## Cost Optimization Tips

1. **Managed Identities are free** — No charge for creating or using them
2. **RBAC roles are free** — Custom roles cost nothing
3. **Destroy after use** — The VM and Storage Account are the only cost drivers
4. **Storage Account** generates minimal cost with empty containers (~$0.02/day)
5. **SSH key** — The terraform expects `~/.ssh/id_rsa.pub`; generate one or update the path

## FinOps Tags

All resources deployed with:

| Tag | Value |
|-----|-------|
| `CostCenter` | `SDCI-Lab` |
| `Environment` | `Training` |
| `Module` | `04-zero-trust-iam` |
| `AzureRegion` | `eastus` |
| `Creator` | `<your-email>` |
| `DestroyAfter` | `<YYYY-MM-DD>` |
