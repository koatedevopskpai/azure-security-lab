# SDCI Lab 03 — Azure: Free Tier & Cost Analysis

## Per-Resource Breakdown

| Resource | Pricing Model | Daily Cost | Free Tier |
|----------|--------------|-----------|-----------|
| VNet + subnets | Free | $0.00 | Always free (per region) |
| NSGs + ASGs | Free | $0.00 | Always free |
| Application Security Groups | Free | $0.00 | Always free |
| Azure Front Door (Standard) | Fixed monthly | ~$0.89 | — |
| WAF Policy | Included with Front Door | $0.00 | Included |
| Public IP (Standard, static) | Per hour | ~$0.00 | First 5 free per sub |
| VM Standard_B1s | Per hour | ~$0.14 | 750 hrs/mo (12 months) |
| Managed Disk Standard_LRS 30GB | Per GB/mo | ~$0.04 | — |
| Defender for Cloud (Foundational) | Free | $0.00 | Always free |
| Defender for Cloud (Enhanced) | Per VM | ~$15/mo per VM | 30-day trial |

## Cost Scenarios

| Scenario | Daily | Monthly |
|----------|-------|---------|
| **Best case** — Free tier + credits available | **~$0.93** | ~$27.90 |
| **Worst case** — No free tier/trial | **~$1.07** | ~$32.10 |

## Why Azure Front Door Not Application Gateway?

Application Gateway WAF_v2 is the more direct equivalent to the ALB+WAF in AWS and HTTP LB+Cloud Armor in GCP, but it costs **~$5.90/day** (over our $1.00 budget cap). Azure Front Door Standard provides equivalent WAF capabilities at **~$0.89/day** and adds global distribution benefits. For the SDCI exam, understanding the WAF rules (OWASP, custom rules, rate limiting) is the same regardless of the front-end service.

## Cost Optimization Tips

1. **Destroy immediately**: Front Door and VM accrue costs continuously
2. **Defender trial**: If you enable enhanced security, disable it immediately after testing
3. **SSH key**: The terraform expects `~/.ssh/id_rsa.pub` — if you don't have one, generate it or update the `admin_ssh_key` block
4. **Public IPs**: Standard SKU static IPs are $0.005/hr (~$0.12/day) after the first 5; this lab uses 1

## FinOps Tags

All resources deployed with:

| Tag | Value |
|-----|-------|
| `CostCenter` | `SDCI-Lab` |
| `Environment` | `Training` |
| `Module` | `03-ngfw-ids-ips` |
| `AzureRegion` | `eastus` |
| `Creator` | `<your-email>` |
| `DestroyAfter` | `<YYYY-MM-DD>` |
