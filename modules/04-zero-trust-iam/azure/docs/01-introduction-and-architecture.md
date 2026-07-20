# SDCI Lab 04 — Azure: Introduction & Architecture

## Objective

Implement Zero Trust principles on Azure using Managed Identities, Custom RBAC Roles, and Scope-Based Access Control — mapping directly to the **SDCI 300-745 exam objective 4.0**.

## Zero Trust Principles Applied

### 1. Never Trust, Always Verify

The VM authenticates to Azure Resource Manager via its **Managed Identity** — every API call is verified at the Azure RBAC layer. Even if the VM is compromised, the attacker must pass RBAC authorization for every operation.

### 2. Least Privilege

The custom RBAC role contains only two `actions`:
- `Microsoft.Storage/storageAccounts/blobServices/containers/read` — list containers
- `Microsoft.Storage/storageAccounts/blobServices/containers/blobs/read` — read blobs

If the VM is compromised, the attacker cannot create, delete, or modify any storage data.

### 3. Scope-Based Access

The role assignment is scoped **specifically to the Storage Account**, not the entire resource group or subscription. The Managed Identity has no permissions outside that Storage Account.

### 4. Workload Identity

The **User-Assigned Managed Identity** is attached to the VM's `identity` block. The VM obtains tokens from the Azure Instance Metadata Service (IMDS) — no client secrets or certificates to manage.

## Architecture

```
                          ┌──────────────────────────────────┐
                          │       Azure Subscription         │
                          │                                  │
                          │   ┌──────────────────┐          │
                          │   │  Public Subnet   │          │
                          │   │  10.0.1.0/24     │          │
                          │   │  NSG: SSH only   │          │
                          │   │                  │          │
                          │   │ ┌──────────────┐ │          │
                          │   │ │ B1s Ubuntu VM│ │          │
                          │   │ │ UAMI attached│ │          │
                          │   │ └──────┬───────┘ │          │
                          │   └────────┼─────────┘          │
                          │            │                     │
                          │            ├─ IMDS endpoint      │
                          │            │  (token retrieval)  │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │ Managed Identity │          │
                          │   │ (principal_id)   │          │
                          │   └────────┬─────────┘          │
                          │            │                     │
                          │            │ Role Assignment     │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │ Custom RBAC Role  │          │
                          │   │ Storage Reader    │          │
                          │   └────────┬─────────┘          │
                          │            │                     │
                          │            ▼                     │
                          │   ┌──────────────────┐          │
                          │   │ Storage Account  │          │
                          │   │ (read-only)      │          │
                          │   └──────────────────┘          │
                          └──────────────────────────────────┘
```

## Key IAM Resources

| Resource | Purpose |
|----------|---------|
| `azurerm_user_assigned_identity` | Workload identity for VM |
| `azurerm_role_definition` | Custom RBAC role with 2 read-only actions |
| `azurerm_role_assignment` | Binds the role to the Managed Identity at Storage Account scope |

## Security Controls Checklist

| Control | Status | Notes |
|---------|--------|-------|
| Workload identity (no keys) | ✅ | Managed Identity — no secrets to rotate |
| Custom least-privilege role | ✅ | Only read operations on Storage Account |
| Scope-bound access | ✅ | Role assigned at resource level, not subscription |
| No static credentials | ✅ | Tokens retrieved from IMDS at runtime |
| SSH access | ⚠️ | Pre-Zero Trust; production should use Bastion or JIT |

## Progression to Full Zero Trust Access

This lab uses SSH with a public IP for simplicity. For production Zero Trust access on Azure:

| Mechanism | Cost | Setup |
|-----------|------|-------|
| **Azure Bastion** | ~$0.40/hr ($9.60/day) | Native to portal, no public IP needed |
| **Just-In-Time VM Access** | Free with Defender for Cloud | 30-day trial, auto-open/close ports |
| **Azure CLI via Bastion** | ~$0.40/hr | `az network bastion ssh` |

## References

- [Azure Managed Identities](https://learn.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/)
- [Azure RBAC Documentation](https://learn.microsoft.com/en-us/azure/role-based-access-control/)
- [Custom Roles](https://learn.microsoft.com/en-us/azure/role-based-access-control/custom-roles)
- [Azure Bastion](https://learn.microsoft.com/en-us/azure/bastion/)
