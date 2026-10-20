# Get-AppPermissions.ps1
# Lists enterprise apps (service principals) with the delegated permissions users have consented to. Read-only.

# Scopes:
#   Application.Read.All               - list service principals
#   DelegatedPermissionGrant.Read.All  - read consent grants (which scopes an app was granted)
Connect-MgGraph -Scopes "Application.Read.All","DelegatedPermissionGrant.Read.All" -NoWelcome

# All consent grants in the tenant. Each grant = one app, one scope string, one principal (user or "all users")
$grants = Get-MgOauth2PermissionGrant -All

# Lookup table: service principal id -> display name, so we can show names instead of ids
$spLookup = @{}
Get-MgServicePrincipal -All -Property "Id,DisplayName,AppId,PublisherName" | ForEach-Object {
    $spLookup[$_.Id] = $_
}

$rows = foreach ($g in $grants) {
    $sp = $spLookup[$g.ClientId]

    # ConsentType "AllPrincipals" = admin consented for everyone; "Principal" = one user consented for themselves
    $consentType = if ($g.ConsentType -eq "AllPrincipals") { "Admin (all users)" } else { "User" }

    [PSCustomObject]@{
        App         = $sp.DisplayName
        Publisher   = $sp.PublisherName
        ConsentType = $consentType
        Scopes      = $g.Scope.Trim()
    }
}

$outDir = Join-Path $PSScriptRoot "..\output\$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$rows | Sort-Object App | Export-Csv -Path (Join-Path $outDir "app-permissions.csv") -NoTypeInformation -Encoding UTF8

# Flag broad scopes on screen
$broad = $rows | Where-Object { $_.Scopes -match "ReadWrite|Mail\.|Files\.|Directory\." }
Write-Host "Apps with consent grants: $($rows.Count). With broad scopes: $($broad.Count)"
$broad | Format-Table App, ConsentType, Scopes -AutoSize

Disconnect-MgGraph | Out-Null