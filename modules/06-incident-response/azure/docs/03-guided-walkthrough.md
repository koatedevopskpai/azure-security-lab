# SDCI Lab 06 — Azure: Guided Walkthrough

## Step 1 — Deploy

```powershell
cd modules\06-incident-response\azure\terraform
terraform init
terraform plan -var="creator=student@example.com"
terraform apply -var="creator=student@example.com" -auto-approve
```

## Step 2 — Verify Normal vs Quarantined

```bash
$cleanIp = $(terraform output -raw vm_clean_ip)
$quarIp  = $(terraform output -raw vm_quarantined_ip)

# Works
ssh -o ConnectTimeout=5 -o StrictHostKeyChecking=no sdciadmin@$cleanIp "echo ACCESSIBLE"

# TIMEOUT
ssh -o ConnectTimeout=5 sdciadmin@$quarIp "echo BLOCKED"
```

## Step 3 — Dynamic Quarantine

```bash
$rg = $(terraform output -raw rg_name | Select -First 1)
# Actually use the literal resource group name
az network vnet subnet update --resource-group sdci-06-az-rg --vnet-name sdci-06-az-vnet --name sdci-06-az-snet --network-security-group $(terraform output -raw quarantine_nsg_id)

# Verify blocked
ssh -o ConnectTimeout=5 sdciadmin@$cleanIp "echo QUARANTINED"

# Release
az network vnet subnet update --resource-group sdci-06-az-rg --vnet-name sdci-06-az-vnet --name sdci-06-az-snet --network-security-group $(terraform output -raw normal_nsg_id)
```

## Step 4 — Cleanup

```powershell
.\cleanup.ps1
```
