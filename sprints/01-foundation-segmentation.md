# Sprint 1 — Foundation & VNet Segmentation (Azure)

**Sprint Goal**: Establish the repository scaffold, shared modules, and implement Module 01 (VNet Segmentation) for Azure. Complete the architecture, Terraform IaC, documentation, and cleanup scripts.

## Epic: Foundation & Network Segmentation

| Story | Status | Deliverable |
|-------|--------|-------------|
| 1.1 Repo scaffold | ✅ Complete | README, ARCHITECTURE.md, COST-GUIDE.md, .gitignore |
| 1.2 Shared modules | ✅ Complete | `shared/scripts/cleanup.ps1`, `shared/templates/module-scaffold.md` |
| 1.3 Azure Terraform IaC | 📋 Planned | `terraform/*.tf` — VNet, subnets, NSGs, route tables, NAT Gateway, bastion |
| 1.4 Azure docs | 📋 Planned | Architecture guide, cost analysis, guided walkthrough |
| 1.5 Git repository | 📋 Planned | Initialize git, commit, push to `github.com/koatedevopskpai/azure-security-lab` |

## Key Decisions Made

1. **Three-tier mapping**: Access → `access` subnet + NSG, Distribution → `distribution` subnet + route table, Core → `core` subnet + NAT Gateway
2. **NAT Gateway**: Only paid resource (~$1.08/day if left running). Required for private subnet egress. Flagged with cost warning.
3. **Local state**: Personal accounts don't have shared backends. Local state is simpler for training.
4. **No Azure Firewall**: NSGs (free) used for Module 01. Azure Firewall introduced in Module 03.

## Cost Forecast for Sprint 1

| Resource | Daily Cost | Monthly (if left running) |
|----------|-----------|--------------------------|
| NAT Gateway | $1.08 | $32.40 |
| VM B1s bastion (free tier) | $0.00 | $0.00 |
| VNet/subnets/NSGs (free) | $0.00 | $0.00 |
| **Total** | **$1.08** | **$32.40** |

## Definition of Done

- [x] Repository scaffold with README, ARCHITECTURE, COST-GUIDE
- [x] Shared cleanup script and module template
- [ ] `terraform init && terraform plan` succeeds without errors
- [ ] `terraform apply` creates VNet, 3 subnets, NSGs, route tables, NAT Gateway
- [ ] Verification steps in walkthrough produce expected results
- [ ] `terraform destroy` cleans up all resources cleanly
- [ ] Git repo initialized and pushed

## Next Steps (Sprint 2)

- Start Module 02 (Remote Access VPN) for Azure
- Mirror remaining GCP/AWS modules
