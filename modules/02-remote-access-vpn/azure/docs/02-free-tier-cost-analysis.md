# Module 02: Remote Access VPN — Cost Analysis (Azure)

## Cost Breakdown

| Resource | Free Tier? | Daily Cost | 2-Hour Session |
|----------|-----------|------------|----------------|
| VNet + subnets | ✅ Always free | $0.00 | $0.00 |
| VPN Gateway (VpnGw1) | ❌ **Not free** | **$0.72** | **$0.06** |
| Public IP | ✅ Free tier* | $0.00 | $0.00 |
| B1s workload VM | ✅ Free tier | $0.00 | $0.00 |
| **Total** | | **$0.72** | **$0.06** |

## Strategy

**Do not leave the VPN Gateway running.** A single 2-hour lab session costs ~$0.06, well under the $1.00 daily cap. Forgetting to destroy costs $0.72/day.
