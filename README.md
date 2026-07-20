# Azure Security Lab

Hands-on security training labs for Microsoft Azure, aligned to **Cisco SDCI 300-745** exam objectives.

## Alignment to Cisco SDCI 300-745

This repo maps the following 300-745 domains into practical Azure implementations:

| 300-745 Domain | Azure Lab Module | Key Azure Services |
|---------------|------------------|-------------------|
| Network segmentation & layered architecture | 01 - VNet Segmentation | VNet, subnets, NSGs, Application Security Groups |
| Remote access & VPN connectivity | 02 - Remote Access VPN | VPN Gateway, P2S, Azure Bastion |
| NGFW, IDS/IPS, zone-based firewalls | 03 - NGFW & IDS/IPS | Azure Firewall Premium, Defender for Cloud, WAF |
| Zero Trust & RBAC | 04 - Zero Trust IAM | Entra ID, Conditional Access, RBAC, PIM |
| SIEM, monitoring, UEBA | 05 - SIEM & UEBA | Microsoft Sentinel, UEBA, Log Analytics |
| Incident response & containment | 06 - Incident Response | NSG quarantine, JIT VM access, Defender |
| DLP & endpoint security | 07 - DLP & Endpoint | Purview, DLP, Microsoft Defender |
| Compliance & auditing | 08 - Compliance | Azure Policy, Defender for Cloud, Compliance Manager |

## Prerequisites

- Azure account with billing enabled (free tier eligible)
- [Azure CLI](https://docs.microsoft.com/cli/azure/install-azure-cli) installed and authenticated
- [Terraform](https://developer.hashicorp.com/terraform/downloads) >= 1.6
- PowerShell 5.1+ (for cleanup scripts)

## Quick Start

```powershell
# Clone the repo
git clone https://github.com/koate-kpai/azure-security-lab.git
cd azure-security-lab

# Navigate to a module
cd modules/01-vpc-segmentation/azure/terraform

# Review costs before deploying
terraform init
terraform plan

# Deploy
terraform apply -auto-approve

# Verify segmentation
az vm list

# Clean up
terraform destroy -auto-approve
```

## Repository Structure

```
azure-security-lab/
├── README.md
├── ARCHITECTURE.md
├── COST-GUIDE.md
├── sprints/
│   └── 01-foundation-segmentation.md
├── modules/
│   └── 01-vpc-segmentation/
│       └── azure/
│           ├── terraform/           # IaC code
│           ├── docs/                # Architecture, cost, walkthrough
│           └── cleanup.ps1          # Module-specific cleanup
└── shared/
    ├── scripts/                    # Common utilities
    └── templates/                  # Module scaffolding
```

## Cost Management

All modules are designed for **free tier first**. Where paid resources are unavoidable, they are explicitly flagged with cost warnings. See [COST-GUIDE.md](./COST-GUIDE.md) for details.

## License

For educational and training purposes only.
