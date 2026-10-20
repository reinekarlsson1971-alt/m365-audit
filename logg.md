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