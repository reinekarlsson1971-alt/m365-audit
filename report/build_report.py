# build_report.py
# Reads the latest audit CSVs and writes a markdown report with findings. No API calls yet.

import csv
from pathlib import Path
from datetime import date

OUTPUT_DIR = Path(__file__).parent.parent / "output"
latest = sorted(OUTPUT_DIR.iterdir())[-1]


def read_csv(name):
    """Read one CSV from the latest output folder into a list of dicts."""
    # def = function keyword, like "function read_csv($name)" in PHP. Indented block is the body.
    with open(latest / name, encoding="utf-8-sig") as f:
        return list(csv.DictReader(f))


users  = read_csv("users.csv")
mfa    = read_csv("mfa.csv")
apps   = read_csv("app-permissions.csv")
guests = read_csv("guests.csv")

# --- Users ---
members_active = [u for u in users if u["Enabled"] == "True" and u["UserType"] == "Member"]
unlicensed     = [u for u in members_active if u["Licenses"] == ""]

# --- MFA ---
no_mfa = [m for m in mfa if m["HasMfa"] == "False"]
mfa_pct = round(100 * len(no_mfa) / len(mfa))      # round() = round(), int division would drop decimals

# --- Apps ---
# Scopes column is a space-separated string. "any(...)" = true if at least one keyword is found.
BROAD = ["ReadWrite", "Mail.", "Files.", "Directory.", "FullControl"]
broad_apps = [a for a in apps if any(k in a["Scopes"] for k in BROAD)]
admin_broad = [a for a in broad_apps if a["ConsentType"].startswith("Admin")]

# --- Guests ---
# Count guests per domain. dict.get(key, 0) returns 0 if key missing, like $arr[$k] ?? 0
domains = {}
for g in guests:
    domains[g["Domain"]] = domains.get(g["Domain"], 0) + 1


def md_table(rows, columns):
    """Build a markdown table from a list of dicts and a list of column names."""
    header = "| " + " | ".join(columns) + " |"        # " | ".join(list) = implode(' | ', $list)
    sep    = "|" + "---|" * len(columns)               # "---|" * 3 = "---|---|---|"
    body   = ["| " + " | ".join(r[c] for c in columns) + " |" for r in rows]
    return "\n".join([header, sep] + body)


# --- Build the report as a list of lines, join at the end ---
lines = []
lines.append(f"# M365 Security Audit – {date.today()}")
lines.append("")
lines.append(f"Source: `{latest.name}`. All data collected read-only via Microsoft Graph.")
lines.append("")

lines.append("## Summary")
lines.append("")
lines.append(f"- Users total: {len(users)} ({len(members_active)} active members, {len(guests)} guests)")
lines.append(f"- Active members without MFA: {len(no_mfa)} of {len(mfa)} ({mfa_pct} %)")
lines.append(f"- Active members without license: {len(unlicensed)}")
lines.append(f"- Apps with broad permissions: {len(broad_apps)} ({len(admin_broad)} admin-consented for all users)")
lines.append(f"- Guest domains: {len(domains)}")
lines.append("")

lines.append("## Active members without MFA")
lines.append("")
lines.append(md_table(no_mfa, ["DisplayName", "UPN", "Methods"]))
lines.append("")

lines.append("## Active members without license")
lines.append("")
lines.append(md_table(unlicensed, ["DisplayName", "UPN", "Created"]))
lines.append("")

lines.append("## Apps with broad permissions")
lines.append("")
lines.append(md_table(broad_apps, ["App", "ConsentType", "Scopes"]))
lines.append("")

lines.append("## Guests per domain")
lines.append("")
# sorted(dict.items(), key=...) sorts the (domain, count) pairs by count, highest first
for domain, count in sorted(domains.items(), key=lambda x: x[1], reverse=True):
    lines.append(f"- {domain}: {count}")
lines.append("")

report_path = latest / "report.md"
report_path.write_text("\n".join(lines), encoding="utf-8")
print(f"Wrote {report_path}")