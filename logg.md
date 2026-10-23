# Logg

## 2026-10-12

- Skript: scripts/Get-UserInventory.ps1 skriver output/<datum>/users.csv
- Användare totalt: 67
- Gäster: X
- Aktiva konton utan licens: X
- Fynd: tenanten saknar Entra ID P1 – SignInActivity ger 403, inga CA-policyer möjliga
- Nästa: MFA-status (skript 2)

## 2026-10-20 – App permissions

Skript: scripts/Get-AppPermissions.ps1 → output/<datum>/app-permissions.csv
48 consent grants, 27 med breda scopes.

| App | Ägare | Används | Åtgärd senare |
|---|---|---|---|
| HubSpot Sales / HubSpot | Sälj | Ja | Behåll |
| Zoom | Alla | Ja | Behåll |
| Zapier Office 365 | ? | Okänt | Utred |
| Upsales | ? | Okänt | Utred |
| Unipile | ? | Okänt | Utred |
| Decisions | ? | Okänt | Utred |
| Mailagent Erik | Erik? | Okänt | Utred – kolla Application permissions |
| CloudDuplicateFinder | ? | Nej? | Troligen ta bort |
| Mailmeteor Dev | ? | Nej? | Troligen ta bort |
| ChatGPT | Alla | Ja | Policybeslut |
| RocketReach | ? | Okänt | Utred |
| M365 MCP Server for Claude | Piccard | Ja | Granska scopes |
| Microsoft Graph Command Line Tools | Piccard | Ja | Ta bort org-consent |

Fynd: Graph CLI fick admin-consent för alla användare vid första inloggning – bocka inte i "Consent on behalf of organization".

## 2026-10-20 – External access

Skript: scripts/Get-ExternalAccess.ps1 → guests.csv
- Security defaults: AV. Ingen P1. → Ingen tenant-wide MFA-tvingning. (HÖG)
- SharePoint sharing: externalUserAndGuestSharing (Anyone-länkar), ingen expiry. (HÖG)
- Gäster: 19, 14 domäner. Utred: ylocap.se.

## 2026-10-20 – Steg 3 klart

Invoke-M365Audit.ps1 kör alla fyra skript, ~100 s.
Huvudfynd:
- 14 av 35 aktiva medlemmar saknar MFA (40 %). Security defaults av, ingen P1 → inget tvingar MFA. (HÖG)
- Anyone-länkar på i SharePoint, ingen expiry. (HÖG)
- 27 consent grants med breda scopes; Mailagent Erik, CloudDuplicateFinder, Mailmeteor Dev, Unipile att utreda. (MEDEL)
- Gäst från ylocap.se att utreda. (MEDEL)
Lärdom: Out-Host i wrapper, Format-Table bara sist i kedjan.

## 2026-10-23 – Python start

- Python venv uppsatt (.venv), aktiveras med .\.venv\Scripts\Activate.ps1
- report/summarize.py läser senaste users.csv och räknar
- Aktiva olicensierade medlemmar: 20