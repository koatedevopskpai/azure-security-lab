# Azure Security Lab — Cost Guide

## FinOps Principles

1. **Free tier first** — All modules default to Azure Free Tier eligible services. Paid services are used only when the learning objective requires them and are explicitly flagged.
2. **Tag everything** — Every resource is tagged with `CostCenter`, `Environment`, `Module`, `Cloud`, `Creator`, and `DestroyAfter`. Use these in Azure Cost Management to track spend per lab.
3. **Clean up immediately** — Run `terraform destroy` and the module's `cleanup.ps1` after each session.
4. **Budget alerts** — Use Azure Cost Management alerts to set a $1 daily budget per lab before starting.

## Free Tier Limits (Relevant to These Labs)

| Service | Free Tier Limit | Applies to Modules |
|---------|----------------|-------------------|
| Virtual Machines | 750 hours/month B1s | 01, 02, 06 |
| VNet | No charge for VNets, subnets | All modules |
| NSGs | No charge | All modules |
| NAT Gateway | **Not free** — ~$0.045/hour | 01, 02 (required for private subnets) |
| VPN Gateway | **Not free** — ~$0.03/hour (trial credits may apply) | 02 |
| Defender for Cloud | Free foundational CSPM | 03, 05 |
| Sentinel | 31-day free trial (up to 1 GB/day) | 05 |

## Module 01 Cost Breakdown

| Resource | Free Tier? | Quantity | Daily Cost | Notes |
|----------|-----------|----------|------------|-------|
| VNet | ✅ Yes | 1 | $0.00 | |
| Subnets (access, dist, core) | ✅ Yes | 3 | $0.00 | |
| NSGs | ✅ Yes | 3 | $0.00 | |
| Route tables | ✅ Yes | 1 | $0.00 | |
| NAT Gateway | ❌ No | 1 | ~$1.08 | Only paid resource. **Delete when not in use.** |
| VM B1s bastion | ✅ Yes | 1 | $0.00 | Within free tier hours |
| Network Watcher | ✅ Yes | 1 | $0.00 | |
| **Total** | | | **~$1.08/day** | |

## Monthly Forecast (All 8 Modules)

| Module | Daily Cost (max) | Monthly (30d) |
|--------|-----------------|---------------|
| 01 — VNet Segmentation | $1.08 | $32.40 |
| 02 — Remote Access VPN | $2.40 | $72.00 |
| 03 — NGFW & IDS/IPS | $3.00 (trial) | $90.00 (trial then ~$15) |
| 04 — Zero Trust IAM | $0.00 | $0.00 |
| 05 — SIEM & UEBA | $0.00 (trial) | $0.00 |
| 06 — Incident Response | $1.08 | $32.40 |
| 07 — DLP & Endpoint | $0.00 | $0.00 |
| 08 — Compliance | $0.00 | $0.00 |
| **Estimated Total** | **~$7.56/day** | **~$226.80** |

> Azure costs are higher than GCP for NAT and VPN. Minimize by destroying resources between sessions.

## Budget Alerts

Create a budget alert via Azure CLI before running any lab:

```bash
az consumption budget create \
  --budget-name "SDCI-Lab-Budget" \
  --amount 50 \
  --time-grain "Monthly" \
  --category "Cost" \
  --start-date $(date +%Y-%m-01) \
  --notifications '{"forecastedGreaterThanBudget": {"enabled": true, "operator": "GreaterThan", "threshold": 80, "contact-emails": ["your@email.com"]}}'
```

## Cleanup Best Practices

1. Run `terraform destroy -auto-approve` — destroys all tagged resources
2. Run the module's `cleanup.ps1` — prints a summary and checks for orphaned resources
3. Verify in Azure Portal: **Cost Management + Billing → Cost Analysis**
4. Check for stray NAT Gateways and Public IPs (most common cause of unexpected charges)
