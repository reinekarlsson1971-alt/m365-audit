# Get-UserInventory.ps1
# Reads all users with license status, writes to CSV. Read-only.
# Note: SignInActivity requires Entra ID P1, which this tenant does not have.

# Connect with minimum scopes:
#   User.Read.All         - read user objects
#   Organization.Read.All - read license (SKU) names
Connect-MgGraph -Scopes "User.Read.All","Organization.Read.All" -NoWelcome

# Build a lookup table: SKU id -> readable name
$skuLookup = @{}
Get-MgSubscribedSku | ForEach-Object {
    $skuLookup[$_.SkuId] = $_.SkuPartNumber
}

# Fetch all users. -Property is required; Graph returns only requested fields.
$users = Get-MgUser -All -Property "DisplayName,UserPrincipalName,AccountEnabled,AssignedLicenses,CreatedDateTime,UserType"

# Shape each user into a flat row for CSV
$rows = $users | ForEach-Object {
    # Translate each license id to its name, join with ";"
    $licenseNames = ($_.AssignedLicenses | ForEach-Object { $skuLookup[$_.SkuId] }) -join ";"

    # Create a custom object = one row in the CSV
    [PSCustomObject]@{
        DisplayName = $_.DisplayName
        UPN         = $_.UserPrincipalName
        Enabled     = $_.AccountEnabled
        UserType    = $_.UserType        # "Member" or "Guest"
        Licenses    = $licenseNames
        Created     = $_.CreatedDateTime
    }
}

# Output folder with today's date, relative to the script's folder
$outDir = Join-Path $PSScriptRoot "..\output\$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null

# Write CSV. -NoTypeInformation removes the "#TYPE" header line.
$rows | Export-Csv -Path (Join-Path $outDir "users.csv") -NoTypeInformation -Encoding UTF8

Write-Host "Wrote $($rows.Count) users to $outDir\users.csv"

Disconnect-MgGraph | Out-Null