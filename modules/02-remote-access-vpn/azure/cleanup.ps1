param([switch]$AutoApprove = $false)

$modulePath = Join-Path $PSScriptRoot "terraform"

Write-Host "╔══════════════════════════════════════════════════════╗" -ForegroundColor Yellow
Write-Host "║  SDCI Lab 02 — Remote Access VPN Cleanup (Azure)  ║" -ForegroundColor Yellow
Write-Host "╚══════════════════════════════════════════════════════╝" -ForegroundColor Yellow
Write-Host "IMPORTANT: Destroying VPN Gateway to stop ~$0.03/hr charges." -ForegroundColor Red

Push-Location $modulePath
try {
    & terraform state list 2>$null
    if (-not $AutoApprove) {
        $confirm = Read-Host "Type 'yes' to destroy"
        if ($confirm -ne "yes") { return }
    }
    & terraform destroy -auto-approve
    Write-Host "`n✓ Cleanup complete!" -ForegroundColor Green
    Write-Host "Check: az network vpn-gateway list" -ForegroundColor White
}
finally { Pop-Location }
