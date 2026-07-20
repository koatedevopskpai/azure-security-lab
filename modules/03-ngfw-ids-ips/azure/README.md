# SDCI Lab 03 — NGFW, IDS/IPS & Zone-Based Firewalls (Azure)

Three-tier security lab for the Cisco SDCI 300-745 exam using Azure native services.

## Architecture

```
Internet → Azure Front Door → WAF → VM (Web) → VM (App)
                                          ↓
                                   Defender for Cloud
```

## Services Used

| Layer | Service | Azure Offering |
|-------|---------|---------------|
| L7 WAF | Azure Front Door + WAF Policy | OWASP 3.2 managed rules (SQLi, XSS), rate limiting |
| L3-4 FW | NSGs + Application Security Groups | Stateful zone-based rules with ASG grouping |
| Threat Detection | Defender for Cloud | Foundational CSPM (free) |

## Cost

| Resource | Daily Cost |
|----------|-----------|
| VNet/NSGs/ASGs | $0.00 |
| WAF Policy | $0.00 |
| Front Door Standard | ~$0.89 |
| VM B1s | ~$0.14 |
| Defender for Cloud (Foundational) | $0.00 |
| **Total** | **~$1.07/day worst case** |

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="creator=your.email@example.com"
terraform apply -var="creator=your.email@example.com" -auto-approve
```

## Test WAF

```bash
# Normal request — allowed
curl -I http://<frontdoor-name>.azurefd.net

# SQL injection — blocked (403)
curl -I "http://<frontdoor-name>.azurefd.net/?id=1' OR '1'='1"

# XSS — blocked (403)
curl -I "http://<frontdoor-name>.azurefd.net/?q=<script>alert(1)</script>"
```

## Cleanup

```powershell
.\cleanup.ps1
```

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
