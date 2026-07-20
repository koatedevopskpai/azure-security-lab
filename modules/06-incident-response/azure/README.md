# SDCI Lab 06 — Incident Response & Containment (Azure)

Quarantine a compromised VM by swapping its subnet's NSG. For SDCI 300-745.

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="creator=you@example.com"
terraform apply -var="creator=you@example.com" -auto-approve
```

## Test

```bash
# 1. SSH to clean VM — works
ssh sdciadmin@$(terraform output -raw vm_clean_ip)

# 2. SSH to quarantined VM — TIMEOUT (deny-all NSG on subnet)

# 3. Quarantine the subnet dynamically
az network vnet subnet update --resource-group sdci-06-az-rg --vnet-name sdci-06-az-vnet --name sdci-06-az-snet --network-security-group $(terraform output -raw quarantine_nsg_id)

# 4. SSH — TIMEOUT (both VMs now isolated)

# 5. Release
az network vnet subnet update --resource-group sdci-06-az-rg --vnet-name sdci-06-az-vnet --name sdci-06-az-snet --network-security-group $(terraform output -raw normal_nsg_id)
```

## Cost

~$0.14/day (B1s VM free tier eligible).

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
