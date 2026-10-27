# Invoke-M365Audit.ps1
# Runs all read-only audit scripts in sequence and reports which succeeded. Nothing here changes the tenant.

# Scripts to run, in order. Paths are relative to this file's folder.
$scripts = @(
    "Get-UserInventory.ps1",
    "Get-MfaStatus.ps1",
    "Get-AppPermissions.ps1",
    "Get-ExternalAccess.ps1"
)

$results = foreach ($name in $scripts) {
    $path = Join-Path $PSScriptRoot $name
    $start = Get-Date

    # try/catch: if one script fails, log it and continue with the next instead of stopping everything
    try {
        & $path | Out-Host                        # Out-Host: print the child script's output to screen instead of capturing it
        $status = "OK"
    }
    catch {
        $status = "FAILED: $($_.Exception.Message)"
    }

    [PSCustomObject]@{
        Script   = $name
        Status   = $status
        Seconds  = [int]((Get-Date) - $start).TotalSeconds
    }
}

Write-Host ""
Write-Host "=== Audit summary $(Get-Date -Format 'yyyy-MM-dd HH:mm') ==="
$results | Format-Table -AutoSize