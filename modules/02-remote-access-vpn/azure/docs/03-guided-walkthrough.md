# Module 02: Remote Access VPN — Guided Walkthrough (Azure)

**Time**: 45 min | **Cost**: ~$0.06 (destroy within 2 hours)

---

## Step 1: Deploy

```powershell
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
```

Note: VPN Gateway takes 15-30 minutes to provision.

---

## Step 2: Generate VPN Client Config

```bash
# Generate client configuration package
az network vpn-client generate \
  --resource-group rg-sdci-02-azure \
  --name sdci-02-azure-gw

# Extract the downloaded zip file
# The zip contains the Azure VPN Client configuration XML
```

---

## Step 3: Connect

1. Download **Azure VPN Client** from the Microsoft Store
2. Import the VPN client configuration
3. Ensure the root certificate is trusted on your machine
4. Connect to the VPN

---

## Step 4: Test

```bash
# From VPN-connected machine
ping 10.0.2.4   # Workload VM private IP (adjust if different)
```

---

## Step 5: Clean Up

```powershell
terraform destroy -auto-approve
.\cleanup.ps1 -AutoApprove
```
