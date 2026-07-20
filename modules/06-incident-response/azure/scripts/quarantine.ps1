# Azure Incident Response — Quarantine/Release a subnet by swapping NSG
param(
    [Parameter(Mandatory = $true)][string]$ResourceGroup,
    [Parameter(Mandatory = $true)][string]$Subnet,
    [Parameter(Mandatory = $true)][string]$Vnet,
    [ValidateSet("quarantine", "release")][string]$Action
)
$ErrorActionPreference = "Stop"

$nsgNormal = $(terraform output -raw normal_nsg_id)
$nsgQuarantine = $(terraform output -raw quarantine_nsg_id)

$targetNsg = if ($Action -eq "quarantine") { $nsgQuarantine } else { $nsgNormal }
$actionLabel = if ($Action -eq "quarantine") { "QUARANTINED" } else { "RELEASED" }

Write-Host "🔒 $actionLabel — associating $targetNsg with subnet $Subnet..."
az network vnet subnet update --resource-group $ResourceGroup --vnet-name $Vnet --name $Subnet --network-security-group $targetNsg
Write-Host "Done. Subnet $Subnet is $actionLabel."
