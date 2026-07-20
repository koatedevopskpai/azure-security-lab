# SDCI Lab 04 — Zero Trust & Identity Access Management (Azure)

Zero Trust IAM lab for the Cisco SDCI 300-745 exam using Azure Managed Identities, RBAC, and custom roles.

## Architecture

```
Developer → SSH → VM → Managed Identity (workload ID)
                           ↓
                  Custom RBAC Role (least privilege)
                           ↓
                  Storage Account (read-only)
```

## Concepts Demonstrated

| Concept | Implementation |
|---------|---------------|
| Workload Identity | User-Assigned Managed Identity on Azure VM |
| Least-Privilege RBAC | Custom role: only read containers and blobs |
| Scope-Based Access | Role assigned at Storage Account scope |
| Policy-as-Code | All RBAC defined in Terraform |

## Cost

| Resource | Daily Cost |
|----------|-----------|
| VNet/NSG | $0.00 |
| Managed Identity / RBAC | $0.00 |
| VM B1s | ~$0.14 |
| Storage Account LRS | ~$0.02 |
| **Total** | **~$0.20/day worst case** |

## Deploy

```powershell
cd terraform
terraform init
terraform plan -var="creator=you@example.com"
terraform apply -var="creator=you@example.com" -auto-approve
```

## Access the VM

```bash
ssh sdciadmin@<public-ip>
```

## Verify Least-Privilege RBAC

```bash
# From within the VM — get an access token for the Managed Identity
TOKEN=$(curl -s 'http://169.254.169.254/metadata/identity/oauth2/token?api-version=2018-02-01&resource=https://storage.azure.com/' -H Metadata:true | jq -r '.access_token')

# List containers (should succeed)
curl -s -H "Authorization: Bearer $TOKEN" "https://<sa-name>.blob.core.windows.net/?comp=list" | xmllint --format -

# Try to delete a container (should fail)
curl -s -X DELETE -H "Authorization: Bearer $TOKEN" "https://<sa-name>.blob.core.windows.net/sdci-lab-data?restype=container"
# Expected: 403 AccessDenied
```

## Cleanup

```powershell
.\cleanup.ps1
```

## Docs

- [01 — Introduction & Architecture](docs/01-introduction-and-architecture.md)
- [02 — Free Tier & Cost Analysis](docs/02-free-tier-cost-analysis.md)
- [03 — Guided Walkthrough](docs/03-guided-walkthrough.md)
