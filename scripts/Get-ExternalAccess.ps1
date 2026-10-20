# Get-ExternalAccess.ps1
# Reads tenant-wide settings for external access: security defaults, SharePoint sharing level, guest accounts. Read-only.

# Scopes:
#   Policy.Read.All                   - read security defaults policy
#   SharePointTenantSettings.Read.All - read SharePoint sharing settings
#   User.Read.All                     - list guest users
Connect-MgGraph -Scopes "Policy.Read.All","SharePointTenantSettings.Read.All","User.Read.All" -NoWelcome

# 1. Security defaults: the baseline MFA enforcement when there is no Conditional Access
$secDefaults = Get-MgPolicyIdentitySecurityDefaultEnforcementPolicy
Write-Host "Security defaults enabled: $($secDefaults.IsEnabled)"

# 2. SharePoint tenant sharing level
#    Values: disabled | existingExternalUserSharingOnly | externalUserSharingOnly | externalUserAndGuestSharing (anyone links)
$sp = Get-MgAdminSharepointSetting
Write-Host "SharePoint sharing capability: $($sp.SharingCapability)"
Write-Host "Anonymous link expiry (days): $($sp.AnonymousLinkExpiryInDays)"

# 3. Guest accounts with creation date and external domain
$guests = Get-MgUser -All -Filter "userType eq 'Guest'" -Property "DisplayName,Mail,CreatedDateTime,AccountEnabled" |
    ForEach-Object {
        [PSCustomObject]@{
            DisplayName = $_.DisplayName
            Mail        = $_.Mail
            Domain      = ($_.Mail -split "@")[-1]   # text after the last @
            Enabled     = $_.AccountEnabled
            Created     = $_.CreatedDateTime
        }
    }

$outDir = Join-Path $PSScriptRoot "..\output\$(Get-Date -Format 'yyyy-MM-dd')"
New-Item -ItemType Directory -Path $outDir -Force | Out-Null
$guests | Sort-Object Domain | Export-Csv -Path (Join-Path $outDir "guests.csv") -NoTypeInformation -Encoding UTF8

# Summary: guests per external domain
Write-Host "Guests: $($guests.Count)"
$guests | Group-Object Domain | Sort-Object Count -Descending | Format-Table Name, Count -AutoSize

Disconnect-MgGraph | Out-Null