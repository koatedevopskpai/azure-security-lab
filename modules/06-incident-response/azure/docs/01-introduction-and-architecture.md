# SDCI Lab 06 — Azure: Introduction & Architecture

## Objective

Implement incident response quarantine on Azure using NSG swap — mapping to **SDCI 300-745 objective 6.0**.

## Quarantine Mechanism

Swap the subnet's NSG association from normal (SSH allowed) to quarantine (deny all). NSGs are stateful, so all existing connections are also dropped.

## Two Methods

| Method | Scope | Speed | Effect |
|--------|-------|-------|--------|
| NSG Swap | Subnet (all VMs) | Seconds | All traffic blocked |
| JIT Access | Per-VM | On-demand | Temporary port opening for investigation |

## Architecture

```
Normal NSG (AllowSSH + AllowOutbound) → SSH ✅
Quarantine NSG (DenyAllInbound + DenyAllOutbound) → SSH ❌
```

## JIT VM Access

Azure Just-In-Time VM access (via Defender for Cloud) allows incident responders to request temporary SSH/RDP access to a quarantined VM. JIT automatically opens ports for a configurable window, then closes them.

## Automation

In production, the NSG swap is triggered by a Logic App or Azure Function responding to a Defender alert.

## References

- [NSG Overview](https://learn.microsoft.com/en-us/azure/virtual-network/network-security-groups-overview)
- [JIT VM Access](https://learn.microsoft.com/en-us/azure/defender-for-cloud/just-in-time-access-usage)
