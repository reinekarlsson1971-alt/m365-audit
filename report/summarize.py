# summarize.py
# Reads the latest users.csv and prints basic counts. First Python script in the project.

import csv                      # built-in CSV reader, like fgetcsv in PHP
from pathlib import Path        # object-oriented file paths, replaces string concatenation

# Folder with dated subfolders: output/2026-10-20, output/2026-10-23, ...
OUTPUT_DIR = Path(__file__).parent.parent / "output"   # __file__ = this script; .parent.parent = repo root

# Pick the newest dated folder. sorted() on folder names works because the date format sorts correctly.
latest = sorted(OUTPUT_DIR.iterdir())[-1]
print(f"Reading from {latest}")                         # f-string = "Reading from {$latest}" in PHP

# Read users.csv into a list of dicts. Each row is a dict with column names as keys.
with open(latest / "users.csv", encoding="utf-8-sig") as f:   # utf-8-sig strips the BOM that Export-Csv writes
    users = list(csv.DictReader(f))

# Counts. A comprehension [x for x in list if cond] = array_filter in one line.
total    = len(users)
guests   = len([u for u in users if u["UserType"] == "Guest"])
disabled = len([u for u in users if u["Enabled"] == "False"])
unlicensed_active = len([u for u in users if u["Enabled"] == "True" and u["Licenses"] == "" and u["UserType"] == "Member"])

print(f"Users: {total}")
print(f"Guests: {guests}")
print(f"Disabled: {disabled}")
print(f"Active without license: {unlicensed_active}")