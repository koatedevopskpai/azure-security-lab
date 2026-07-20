param(
    [Parameter(Mandatory = $false)]
    [switch]$AutoApprove = $false
)

$modulePath = Join-Path $PSScriptRoot "terraform"

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  SDCI Lab 01 — VNet Segmentation Cleanup (Azure)  ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host ""

Push-Location $modulePath
try {
    Write-Host "Resources managed by Terraform:" -ForegroundColor Cyan
    & terraform state list 2>$null

    if (-not $AutoApprove) {
        Write-Host ""
        Write-Host "WARNING: This will destroy ALL resources in Lab 01." -ForegroundColor Red
        Write-Host "NAT Gateway (~$1.08/day) will be removed." -ForegroundColor Yellow
        $confirm = Read-Host "Type 'yes' to proceed"
        if ($confirm -ne "yes") { Write-Host "Cleanup cancelled." -ForegroundColor Green; return }
    }

    Write-Host "Running terraform destroy..." -ForegroundColor Yellow
    if ($AutoApprove) { & terraform destroy -auto-approve }
    else { & terraform destroy }

    Write-Host "`n✓ Cleanup complete!" -ForegroundColor Green
    Write-Host "`n=== Post-Cleanup Checklist ===" -ForegroundColor Cyan
    Write-Host "1. Check Azure Cost Management: https://portal.azure.com/#view/Microsoft_Azure_CostManagement" -ForegroundColor White
    Write-Host "2. Verify no orphaned NAT Gateways: az network nat gateway list" -ForegroundColor White
    Write-Host "3. Verify no remaining resources in resource group: az resource list --resource-group rg-sdci-01-azure" -ForegroundColor White
}
finally { Pop-Location }
