# ask_claude.py
# Sends the latest report.md to Claude and asks for prioritized remediation. First API call in the project.

import os
from pathlib import Path
from dotenv import load_dotenv     # reads .env into environment variables
import anthropic                   # official SDK

load_dotenv()                      # after this, os.environ["ANTHROPIC_API_KEY"] exists; the SDK picks it up automatically

OUTPUT_DIR = Path(__file__).parent.parent / "output"
latest = sorted(OUTPUT_DIR.iterdir())[-1]
report = (latest / "report.md").read_text(encoding="utf-8")

# System prompt = the role and rules. User message = the task plus the data.
SYSTEM = """You are a Microsoft 365 security consultant reviewing an audit of a small Swedish company tenant.
Context: the tenant has no Entra ID P1, so Conditional Access is unavailable. Security defaults are disabled.
SharePoint allows anonymous 'Anyone' links with no expiry.
Answer in Swedish. Be concrete and brief. Do not invent facts not present in the report."""

PROMPT = f"""Här är auditrapporten:

{report}

Ge en prioriterad åtgärdslista: max 8 punkter, viktigast först.
För varje punkt: vad, varför (risk), och hur (admin center-sökväg eller PowerShell-cmdlet, bara Get-/Set- namn, inga fullständiga skript)."""

client = anthropic.Anthropic()     # reads the key from the environment

response = client.messages.create(
    model="claude-sonnet-5",
    max_tokens=1500,
    system=SYSTEM,
    messages=[{"role": "user", "content": PROMPT}],
)

# response.content is a list of blocks. Some models return a "thinking" block before the "text" block,
# so filter on type instead of assuming position.
answer = "\n".join(block.text for block in response.content if block.type == "text")

out_path = latest / "recommendations.md"
out_path.write_text(answer, encoding="utf-8")
print(answer)
print(f"\nWrote {out_path}")
print(f"Tokens in: {response.usage.input_tokens}, out: {response.usage.output_tokens}")