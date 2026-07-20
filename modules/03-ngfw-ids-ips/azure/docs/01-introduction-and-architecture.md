# SDCI Lab 03 — Azure: Introduction & Architecture

## Objective

Build a multi-layered security defence on Azure demonstrating WAF (Azure Front Door + WAF Policy), zone-based firewalls (NSGs + Application Security Groups), and threat detection (Defender for Cloud) — mapping directly to the **SDCI 300-745 exam objective 3.0**.

## Three-Layer Security Architecture

### Layer 1 — Azure Front Door + WAF Policy (Application Layer Firewall / NGFW)

Azure Front Door is a global Layer 7 load balancer with an integrated WAF policy.

- **OWASP 3.2 SQLi rules** — Blocks SQL injection patterns (`942110`, `942120`, `942210`)
- **OWASP 3.2 XSS rules** — Blocks cross-site scripting (`941110`, `941120`)
- **Rate limit custom rule** — Drops requests from any IP exceeding 200 requests/minute

### Layer 2 — NSGs + Application Security Groups (Zone-Based Firewall)

| Zone | Resource | Inbound | Egress | Philosophy |
|------|----------|---------|--------|------------|
| **Web** | NSG + ASG | HTTP from VNet only, SSH from anywhere | All traffic | _Default deny — VNet-internal HTTP_ |
| **App** | NSG + ASG | HTTP from Web ASG only | All traffic | _Micro-segmentation — App only trusts Web_ |

### Layer 3 — Defender for Cloud (Threat Detection / IDS)

Defender for Cloud provides:

- Foundational CSPM (free): continuous assessment of security configurations
- Enhanced security (30-day trial): adaptive application controls, fileless attack detection, network map, just-in-time VM access
- Security alerts & regulatory compliance dashboards

## Network Topology

```
                          ┌──────────────────────────────┐
                          │         Azure Subscription    │
                          │                              │
                          │   ┌─── Front Door ────┐      │
                          │   │  (Global L7)      │      │
                          │   └────────┬──────────┘      │
                          │            │ HTTP/80          │
                          │            ▼                  │
                          │ ┌────────────────────┐       │
                          │ │  Web Subnet        │       │
                          │ │  10.0.1.0/24       │       │
                          │ │  ┌──────────────┐  │       │
                          │ │  │ Web NSG + ASG │  │       │
                          │ │  │ HTTP:VNet     │  │       │
                          │ │  │ SSH:0.0.0.0/0 │  │       │
                          │ │  └──────────────┘  │       │
                          │ │  ┌──────────────┐  │       │
                          │ │  │ nginx VM     │  │       │
                          │ │  │ (B1s)        │  │       │
                          │ │  └──────────────┘  │       │
                          │ └────────┬───────────┘       │
                          │          │ HTTP/80            │
                          │          ▼                    │
                          │ ┌────────────────────┐       │
                          │ │  App Subnet        │       │
                          │ │  10.0.2.0/24       │       │
                          │ │  ┌──────────────┐  │       │
                          │ │  │ App NSG + ASG │  │       │
                          │ │  │ HTTP:Web ASG  │  │       │
                          │ │  └──────────────┘  │       │
                          │ └────────────────────┘       │
                          │                              │
                          │   Defender for Cloud         │
                          │   (Foundational CSPM)        │
                          └──────────────────────────────┘
```

## Key Takeaway

In enterprise environments (and the SDCI exam), security is never single-layer. Combining **Front Door WAF (L7) + NSGs (L3-4) + Defender for Cloud (IDS)** provides defense-in-depth:

- WAF stops application-level exploits
- NSGs + ASGs enforce zone boundaries and micro-segmentation
- Defender for Cloud catches configuration drift and suspicious activity

## References

- [Azure WAF on Front Door](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)
- [Azure NSGs](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [Application Security Groups](https://learn.microsoft.com/en-us/azure/virtual-network/application-security-groups)
- [Azure Defender for Cloud](https://learn.microsoft.com/en-us/azure/defender-for-cloud/)
