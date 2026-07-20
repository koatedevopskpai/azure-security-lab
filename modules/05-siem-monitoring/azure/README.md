# SDCI Lab 05 — SIEM, Monitoring & UEBA (Azure)

SIEM and monitoring lab for the Cisco SDCI 300-745 exam using Azure Log Analytics, KQL queries, and log alerts.

## Architecture

```
Resource Logs → Log Analytics → KQL Query → Alert Rule → Action Group
                                                              ↓
                                                          Notification
```

## Concepts Demonstrated

| Concept | Implementation |
|---------|---------------|
| Centralized Logging | Log Analytics Workspace |
| Log Forwarding | Diagnostic settings on NSG + VM |
| Security Analytics | KQL saved query (SSH failure analysis) |
| Alerting | Log Alert Rule on SSH threshold breach |

## Cost

| Resource | Daily Cost |
|----------|-----------|
| VNet/NSG | $0.00 |
| Log Analytics (free tier) | $0.00 |
| VM B1s | ~$0.14 |
| Alert rules / Action groups | $0.00 |
| **Total** | **~$0.20/day** |

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="creator=you@example.com"
terraform apply -var="creator=you@example.com" -auto-approve
```

## Verify Monitoring Pipeline

```bash
# 1. Generate SSH traffic
ssh fakeuser@<PUBLIC_IP>

# 2. Query Log Analytics (KQL)
AzureDiagnostics
| where Category == "NetworkSecurityGroupEvent"
| where flowStatus_s == "F"
| where OperationName contains "FlowEvent"

# 3. Check the saved query
# Log Analytics → Saved Queries → SDCI Lab 05 → SSH Connection Analysis

# 4. Check the alert
# Monitor → Alerts → sdci-05-az-high-ssh
```

## Cleanup

```powershell
.\cleanup.ps1
```

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
