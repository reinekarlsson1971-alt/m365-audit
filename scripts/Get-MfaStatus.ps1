# Get-MfaStatus.ps1
# Lists registered authentication methods per user, flags users without MFA. Read-only.

# Scopes:
#   User.Read.All                      - list users
#   UserAuthenticationMethod.Read.All  - read each user's registered methods
Connect-MgGraph -Scopes "User.Read.All","UserAuthenticationMethod.Read.All" -NoWelcome

# Only members with enabled accounts - guests and disabled accounts are out of scope here
$users = Get-MgUser -All -Property "Id,DisplayName,UserPrincipalName,AccountEnabled,UserType" |
    Where-Object { $_.AccountEnabled -eq $true -and $_.UserType -eq "Member" }

$rows = foreach ($u in $users) {
    # One Graph call per user: returns a list of method objects
    $methods = Get-MgUserAuthenticationMethod -UserId $u.Id

    # Each method has an @odata.type like "#microsoft.graph.phoneAuthenticationMethod".
    # Strip the prefix so we get readable names.
    $types = $methods | ForEach-Object {
        $_.AdditionalProperties["@odata.type"] -replace "#microsoft.graph.", "" -replace "AuthenticationMethod", ""
    }

    # "password" is not MFA. Anything else counts as a second factor.
    $mfaTypes = $types | Where-Object { $_ -ne "password" }

    [PSCustomObject]@{
        DisplayName = $u.DisplayName
        UPN         = $u.UserPrincipalName
        HasMfa      = ($mfaTypes.Count -gt 0)
        Methods     = ($types -join ";")
    }
}

$outDir = Join-Path $PSScriptRoot "..\output\$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$rows | Export-Csv -Path (Join-Path $outDir "mfa.csv") -NoTypeInformation -Encoding UTF8

# Summary to screen
$noMfa = ($rows | Where-Object { -not $_.HasMfa }).Count
Write-Host "Checked $($rows.Count) active members. Without MFA: $noMfa"

Disconnect-MgGraph | Out-Null
