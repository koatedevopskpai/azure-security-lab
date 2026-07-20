# SDCI Lab 05 — Azure: Introduction & Architecture

## Objective

Deploy a complete SIEM monitoring pipeline on Azure — Log Analytics Workspace, diagnostic settings, KQL saved queries, and log alert rules — mapping directly to **SDCI 300-745 exam objective 5.0**.

## Monitoring Pipeline Architecture

### Ingestion Layer — Diagnostic Settings

Azure resources can emit diagnostic logs and metrics to Log Analytics via **diagnostic settings**. In this lab, we enable diagnostic settings on:

- **Network Security Group** — sends `NetworkSecurityGroupEvent` (flow events) and `NetworkSecurityGroupRuleCounter` (rule hit counts) to Log Analytics
- **Virtual Machine** — sends `AllMetrics` (CPU, disk, network IO) to Log Analytics

### Storage Layer — Log Analytics Workspace

Log Analytics is the central SIEM repository. It stores all log data with configurable retention (30 days in this lab). Key features:

- Kusto Query Language (KQL) for analysis
- Saved queries for reusable analytics
- Integration with Azure Monitor Alerts
- Free tier: 5 GB/month ingestion

### Analysis Layer — KQL Saved Queries

The saved query `SSH Connection Analysis` demonstrates a typical security analytics pattern:

```
AzureDiagnostics
| where Category == "NetworkSecurityGroupEvent"
| where flow_s contains "I" and flowStatus_s == "F"
| extend DestinationPort = extract(@":([0-9]+)$", 1, flow_s)
| where DestinationPort == "22"
| project TimeGenerated, SourceIP, DestinationPort
```

This query filters NSG flow events to find blocked inbound SSH connections.

### Alerting Layer — Log Alert Rule

The alert rule `sdci-05-az-high-ssh` runs the KQL query every 5 minutes. If the query returns any results (>10 SSH failures in 5 minutes), the alert fires and notifies the action group.

## Architecture Diagram

```
                          ┌──────────────────────────────────┐
                          │       Azure Subscription         │
                          │                                  │
                          │   External SSH attempt           │
                          │   (synthetic traffic)            │
                          │          │                       │
                          │          ▼                       │
                          │   ┌──────────────────┐          │
                          │   │  Public Subnet   │          │
                          │   │  10.0.1.0/24     │          │
                          │   │  NSG: SSH allow  │          │
                          │   │                  │          │
                          │   │ ┌──────────────┐ │          │
                          │   │ │ B1s Ubuntu VM│ │          │
                          │   │ └──────────────┘ │          │
                          │   └────────┬─────────┘          │
                          │            │ Diag settings       │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │ Log Analytics    │          │
                          │   │ Workspace        │          │
                          │   │ (free tier)      │          │
                          │   └────┬──────┬──────┘          │
                          │        │      │                  │
                          │        ▼      ▼                  │
                          │   ┌────────┐ ┌───────────┐      │
                          │   │ Saved  │ │ Log Alert │      │
                          │   │ Query  │ │ Rule      │      │
                          │   └────────┘ └─────┬─────┘      │
                          │                    │             │
                          │                    ▼             │
                          │   ┌──────────────────┐          │
                          │   │ Action Group     │          │
                          │   │ (notification)   │          │
                          │   └──────────────────┘          │
                          └──────────────────────────────────┘
```

## SIEM Comparison: Azure vs Traditional

| Capability | Traditional SIEM | Azure Log Analytics |
|------------|-----------------|-------------------|
| Log ingestion | Heavy agents | Settings-based |
| Storage | Self-managed | Managed, 30-day default |
| Query language | Vendor-specific | KQL (Kusto) |
| Dashboards | Custom | Workbooks |
| UEBA | Salesforce | Microsoft Sentinel |
| Integration | Complex APIs | Native Azure services |

## Azure Sentinel Note

Microsoft Sentinel is Azure's cloud-native SIEM and UEBA solution. It sits on top of Log Analytics and adds:

- Security information and event management
- UEBA (User and Entity Behavior Analytics)
- SOAR (Security Orchestration, Automation, Response)
- Threat intelligence
- Connectors for 300+ data sources

Sentinel costs ~$2.46/GB ingested. This lab uses the Log Analytics free tier. To enable Sentinel, navigate to the Log Analytics workspace → Sentinel → Enable.

## References

- [Log Analytics Overview](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/log-analytics-overview)
- [Kusto Query Language](https://learn.microsoft.com/en-us/azure/data-explorer/kusto/query/)
- [Azure Monitor Alerts](https://learn.microsoft.com/en-us/azure/azure-monitor/alerts/)
- [Microsoft Sentinel](https://learn.microsoft.com/en-us/azure/sentinel/)
