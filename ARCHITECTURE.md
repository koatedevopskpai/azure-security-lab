# Azure Security Lab — Architecture

## Design Philosophy

These labs translate enterprise network security concepts from Cisco SDCI 300-745 into idiomatic Azure implementations. Azure's VNet constructs — subnets, NSGs, Application Security Groups, and Route Tables — provide native segmentation capabilities that align well with the Cisco three-tier model.

## Cross-Module Architecture

```
[User Devices] ──> [Access Subnet] ──> [NSG/ASG] ──> [Distribution Subnet] ──> [Core Subnet] ──> [Azure Firewall/NAT]
                        │                     │                        │
                        │  [Defender for Cloud / Sentinel]             │
                        └──────────┴───────────────────────────────────┘
                                              │
                                     [Log Analytics]
                                              │
                                     [Microsoft Sentinel]
```

## Module 01: VNet Segmentation Architecture

### Mapping: Cisco 3-Tier → Azure

| Cisco Layer | Azure Resource | Purpose |
|-------------|---------------|---------|
| Access Layer | `access` subnet (10.0.1.0/24) + NSG | End-user device connectivity, port security |
| Distribution Layer | `distribution` subnet (10.0.2.0/24) + Route Table | Inter-zone policy enforcement, forced tunneling |
| Core Layer | `core` subnet (10.0.3.0/24) + NAT Gateway | Backend services, managed egress |
| Micro-segmentation | Application Security Groups (ASGs) | Workload-level isolation by application role |

### Traffic Flow Logic

1. **User-to-internal**: Bastion (or Azure Bastion) in access subnet reaches management interfaces on allowed ports
2. **Zone isolation**: NSG rules block cross-subnet traffic by default; explicit allow rules for permitted flows
3. **Internet egress**: Core subnet instances use Azure NAT Gateway for outbound connectivity
4. **Lateral movement prevention**: ASGs enforce that only instances in the same application group can communicate, regardless of subnet placement

### Key Decision: NSGs vs Azure Firewall

For Module 01, we use NSGs (free tier) rather than Azure Firewall (paid). NSGs provide stateful filtering at the subnet and NIC level — sufficient for the segmentation patterns demonstrated here. Azure Firewall is introduced in Module 03 for full NGFW capabilities.

## Tagging Standards

Every resource in every module carries these mandatory tags:

| Tag Key | Value | Purpose |
|---------|-------|---------|
| `CostCenter` | `SDCI-Lab` | Group all lab costs in billing exports |
| `Environment` | `Training` | Distinguish lab from production |
| `Module` | e.g. `01-vnet-segmentation` | Per-module cost tracking |
| `Cloud` | `azure` | Cross-cloud cost comparison |
| `Creator` | (user input) | Who deployed this |
| `DestroyAfter` | `2026-08-20` | Safety net date |

## State Management

Labs use **local Terraform state** by design. Rationale:
- No shared storage account backend required
- Simple cleanup with `terraform destroy`
- Zero cost for state storage

> For production deployments, migrate to an Azure Storage Account backend with locking. See `shared/templates/`.
