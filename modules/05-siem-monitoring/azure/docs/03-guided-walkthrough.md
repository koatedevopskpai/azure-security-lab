# SDCI Lab 05 — Azure: Guided Walkthrough

## Prerequisites

- Azure CLI installed and logged in
- Terraform ≥ 1.6
- SSH key pair at `~/.ssh/id_rsa.pub`

## Step 1 — Deploy

```powershell
cd modules\05-siem-monitoring\azure\terraform
terraform init
terraform plan -var="creator=student@example.com"
terraform apply -var="creator=student@example.com" -auto-approve
```

## Step 2 — Generate Log Traffic

From any machine, attempt SSH to the VM:

```bash
ssh invalid@$(terraform output -raw vm_public_ip)
```

Repeat 10-15 times. This generates NSG flow events that Log Analytics captures.

## Step 3 — Query Log Analytics

Open the Log Analytics query URL:

```
terraform output log_analytics_url
```

Run the saved query by navigating to **Saved Queries → SDCI Lab 05 → SSH Connection Analysis**.

Or run this KQL query directly:

```kusto
AzureDiagnostics
| where Category == "NetworkSecurityGroupEvent"
| where OperationName == "NetworkSecurityGroupFlowEvents"
| where flow_s contains "I"
| where flowStatus_s == "F"
| extend
    SourceIP = extract(@"([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)", 1, flow_s),
    DestinationPort = extract(@":([0-9]+)$", 1, flow_s)
| where DestinationPort == "22"
| project TimeGenerated, SourceIP, DestinationPort
| order by TimeGenerated desc
```

## Step 4 — View Alert Rule

Navigate to **Monitor → Alerts → Alert rules → sdci-05-az-high-ssh**.

- Review the KQL query in the alert condition
- Check the action group settings
- View **Alert instances** to see if the threshold was breached

## Step 5 — Create a Log Analytics Workbook (Optional)

Navigate to **Log Analytics → Workbooks → New**.

Add a query tile with the SSH analysis KQL query and add it to a dashboard. Workbooks are Azure's interactive reporting tool for SIEM data.

## Step 6 — Cleanup

```powershell
cd modules\05-siem-monitoring\azure
.\cleanup.ps1
```

## Troubleshooting

| Problem | Solution |
|---------|----------|
| No data in Log Analytics | Diagnostic settings take 5-15 min to stream data |
| KQL query returns no results | NSG flow logs use `flow_s` field; check actual format in Log Analytics |
| Alert not firing | Alert rule checks every 5 min; wait for the next evaluation cycle |
| `ssh: connect to host` timeout | NSG rule allows SSH on port 22; check `az network nsg rule list` |
