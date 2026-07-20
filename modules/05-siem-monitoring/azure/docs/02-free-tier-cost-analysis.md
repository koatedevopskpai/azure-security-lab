# SDCI Lab 05 — Azure: Free Tier & Cost Analysis

## Per-Resource Breakdown

| Resource | Pricing Model | Daily Cost | Free Tier |
|----------|--------------|-----------|-----------|
| VNet + Subnet | Free | $0.00 | Always free |
| NSG | Free | $0.00 | Always free |
| NSG Diagnostic Logs | $0.02/GB ingested | ~$0.02 | Minimal |
| Log Analytics | $2.46/GB ingested (pay-as-you-go) | $0.00 | 5 GB/month free |
| Saved KQL Query | Free | $0.00 | Free |
| Log Alert Rule | $0.06/rule/day | $0.00 | 1st 100 queries free |
| Action Group | Free (email) | $0.00 | 1,000 emails free/mo |
| Public IP (Standard) | $0.005/hr | ~$0.00 | First 5 free |
| VM B1s | $0.006/hr | ~$0.14 | 750 hrs/mo free |
| Managed Disk 30 GB | $0.05/GB/mo | ~$0.04 | — |

## Cost Scenarios

| Scenario | Daily | Monthly |
|----------|-------|---------|
| **Best case** — Free tier | **~$0.00** | ~$0.00 |
| **Worst case** — No free tier | **~$0.20** | ~$6.00 |

## Cost vs On-Premises SIEM

| Factor | Traditional SIEM | Azure Log Analytics |
|--------|-----------------|-------------------|
| Infrastructure | Servers + storage | Managed (no infra) |
| Ingestion | $1-5/GB/day | $2.46/GB (pay-as-you-go) |
| Retention | Hardware-limited | Configurable + Archiving |
| Upfront cost | $50k-500k | $0 (usage-based) |

## FinOps Tags

| Tag | Value |
|-----|-------|
| `CostCenter` | `SDCI-Lab` |
| `Module` | `05-siem-monitoring` |
| `AzureRegion` | `eastus` |
| `Creator` | `<your-email>` |
