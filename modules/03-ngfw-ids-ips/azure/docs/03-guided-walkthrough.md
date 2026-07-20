# SDCI Lab 03 — Azure: Guided Walkthrough

## Prerequisites

- Azure CLI installed and logged in (`az login`)
- Terraform ≥ 1.6
- SSH key pair at `~/.ssh/id_rsa.pub` (or update the path in `main.tf`)
- An Azure subscription with Contributor permissions

## Step 1 — Deploy Infrastructure

```powershell
cd modules\03-ngfw-ids-ips\azure\terraform
terraform init
terraform plan -var="creator=student@example.com"
terraform apply -var="creator=student@example.com" -auto-approve
```

**Expected output**: `Apply complete! Resources: <N> added.` + Front Door hostname in outputs.

## Step 2 — Verify WAF Is Active

Grab the Front Door hostname from `terraform output`:

```powershell
$fd = terraform output -raw frontdoor_hostname
```

**Test 1 — Normal request** (should return 200):

```bash
curl -I http://$fd
```

**Test 2 — SQL injection attempt** (should return 403 Forbidden):

```bash
curl -I "http://$fd/?id=1' OR '1'='1"
```

**Test 3 — XSS attempt** (should return 403):

```bash
curl -I "http://$fd/?q=<script>alert('xss')</script>"
```

## Step 3 — Verify Zone-Based Firewall (NSG + ASG)

Check which ASG the web VM belongs to:

```powershell
az vm show -g sdci-03-az-rg -n sdci-03-az-vm-web --query "networkProfile"
```

Verify in the Portal that the App subnet NSG only allows inbound from `Web-ASG`:

```powershell
az network nsg rule list -g sdci-03-az-rg --nsg-name sdci-03-az-nsg-app -o table
```

## Step 4 — Explore Defender for Cloud

Navigate to **Microsoft Defender for Cloud → Recommendations** in the Azure Portal.

- View the **Secure Score** for your subscription
- Browse **Security recommendations** — many will flag your VM for missing anti-malware, encryption, etc.
- Check **Inventory** to see discovered resources
- Note: Foundational CSPM (free tier) gives recommendations only; alerts require the enhanced trial

## Step 5 — Examine WAF Logs

Enable Front Door diagnostics:

```powershell
az monitor diagnostic-settings create --name "waf-logs" --resource <frontdoor-resource-id> --logs '[{"category":"FrontdoorWebApplicationFirewallLog","enabled":true}]' --workspace <log-analytics-workspace-id>
```

Query blocked requests in Log Analytics:

```kusto
AzureDiagnostics
| where Category == "FrontdoorWebApplicationFirewallLog"
| where action_s == "Block"
| project TimeGenerated, ruleName_s, clientIp_s, requestUri_s
```

## Step 6 — Cleanup

```powershell
cd modules\03-ngfw-ids-ips\azure
.\cleanup.ps1
```

Verify in Azure Portal: all resources destroyed.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `curl` gets `curl: (6) Could not resolve host` | Front Door provisioning takes 3-5 mins; wait and retry |
| `terraform apply` fails on VM SSH key | Ensure `~/.ssh/id_rsa.pub` exists, or update `main.tf` with your public key path |
| WAF returns 200 on SQLi test | Verify WAF policy is associated (check `frontend_endpoint` block); Front Door DNS may be cached |
| Defender for Cloud shows nothing | Foundational CSPM scans periodically; wait 15 mins or trigger a vulnerability assessment |
| Front Door returns 502 | The backend VM may not have nginx running; SSH in and check `systemctl status nginx` |
