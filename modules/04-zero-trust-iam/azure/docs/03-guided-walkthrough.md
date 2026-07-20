# SDCI Lab 04 — Azure: Guided Walkthrough

## Prerequisites

- Azure CLI installed and logged in (`az login`)
- Terraform ≥ 1.6
- SSH key pair at `~/.ssh/id_rsa.pub` (or update the path in `main.tf`)
- An Azure subscription with Contributor permissions

## Step 1 — Deploy Infrastructure

```powershell
cd modules\04-zero-trust-iam\azure\terraform
terraform init
terraform plan -var="creator=student@example.com"
terraform apply -var="creator=student@example.com" -auto-approve
```

**Expected output**: `Apply complete! Resources: <N> added.`

## Step 2 — Access the VM

```bash
$ip = terraform output -raw vm_public_ip
ssh sdciadmin@$ip
```

## Step 3 — Verify Managed Identity Token

Once inside the VM, obtain an access token for the Managed Identity:

```bash
# Request a token from the Azure Instance Metadata Service
TOKEN=$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/' -H Metadata:true | jq -r '.access_token')

# Decode the token to see the claims
echo $TOKEN | cut -d. -f2 | base64 -d 2>/dev/null | jq .
```

## Step 4 — Verify Least-Privilege RBAC

```bash
# Get the storage account name from terraform output
SA_NAME=$(terraform output -raw storage_account_name)   # Run this from your local machine

# From within the VM, list containers (should succeed)
curl -s -H "Authorization: Bearer $TOKEN" "https://$SA_NAME.blob.core.windows.net/?comp=list"

# Try to create a container (should fail — custom role has no write)  
curl -s -X PUT -H "Authorization: Bearer $TOKEN" "https://$SA_NAME.blob.core.windows.net/new-container?restype=container"
# Expected: 403 (AccessDenied) — the role doesn't include create permission

# Try to delete the container (should fail)
curl -s -X DELETE -H "Authorization: Bearer $TOKEN" "https://$SA_NAME.blob.core.windows.net/sdci-lab-data?restype=container"
# Expected: 403 (AccessDenied)
```

## Step 5 — Verify Scope-Bound Access

The role is scoped to the Storage Account only. Try to access another Azure resource:

```bash
# Try to list VMs (should fail — no RBAC on Compute)
curl -s -H "Authorization: Bearer $(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://management.azure.com/' -H Metadata:true | jq -r '.access_token')" \
  "https://management.azure.com/subscriptions/$(curl -s -H Metadata:true http://169.254.169.254/metadata/instance?api-version=2021-02-01 | jq -r '.compute.subscriptionId')/providers/Microsoft.Compute/virtualMachines?api-version=2023-03-01"
# Expected: 403 (AccessDenied)
```

## Step 6 — Examine RBAC Configuration

From your local machine:

```bash
# View the custom role definition
az role definition list --name sdci-04-az-custom-role

# View role assignments on the storage account
az role assignment list --scope $(terraform output -raw resource_group_name) --assignee $(terraform output -raw managed_identity_principal_id)
```

## Step 7 — Cleanup

```powershell
cd modules\04-zero-trust-iam\azure
.\cleanup.ps1
```

Verify in Azure Portal: all resources destroyed.

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `ssh: connect to host ...` timeout | NSG rule may not allow SSH; check `az network nsg rule list` |
| Token request fails | Managed Identity may not be attached; verify in VM → Identity in Portal |
| `curl: (60) SSL certificate` | Azure endpoint requires TLS; accept cert with `-k` or use `az storage` CLI |
| `403 (AccessDenied)` on list | Role assignment may not have propagated; wait 2-3 minutes |
| `terraform apply` fails on SA name | Storage account names must be 3-24 chars, lowercase alphanumeric only |
