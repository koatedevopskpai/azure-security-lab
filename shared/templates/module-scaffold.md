# Azure Module Scaffold Template

## Directory Structure

```
modules/{NN}-{module-name}/
└── azure/
    ├── terraform/
    │   ├── versions.tf
    │   ├── providers.tf
    │   ├── variables.tf
    │   ├── locals.tf
    │   ├── main.tf
    │   ├── networking.tf
    │   ├── security.tf
    │   ├── bastion.tf
    │   ├── outputs.tf
    │   └── cost-estimate.tf
    ├── docs/
    │   ├── 01-introduction-and-architecture.md
    │   ├── 02-free-tier-cost-analysis.md
    │   └── 03-guided-walkthrough.md
    ├── cleanup.ps1
    └── README.md
```

## Terraform Design Rules

1. **Azure naming conventions** — use `{prefix}-{resource-type}-{suffix}` with 80-char max.
2. **Resource groups** — one RG per module. Name pattern: `rg-{name_prefix}`.
3. **NSGs over Azure Firewall (Module 01)** — NSGs are free; Azure Firewall is introduced in Module 03.
4. **NAT Gateway toggle** — always include an `enable_nat` variable.
5. **Tag enforcement** — every resource uses `tags = local.tags`. Azure requires tags on most resources.
6. **Cost estimate** — always include a `cost-estimate.tf` that prints during plan.
