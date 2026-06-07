#!/usr/bin/env python3
"""Generate TRANSLATIONS_TODO.json for hand-off to a translation LLM.

Finds every key that exists in app_en.arb but is missing from app_hi.arb
(i.e. newly-added English-first strings that have not been translated yet)
and emits them in the flat array format the user requested:

[
  {
    "key": "internalKey",         # used by apply_translations.py to merge back
    "english": "My english string",
    "hindi": "", "marathi": "", "bengali": "", "punjabi": "",
    "tamil": "", "telgu": "", "malyalam": "", "kannada": ""
  },
  ...
]

The translation LLM only fills the language columns; leave "key" + "english"
untouched. Run from repo root:  python3 lib/l10n/gen_translations_json.py
"""
import json, os, sys

SCRIPT_DIR = os.path.dirname(os.path.abspath(__file__))


def _repo_root(start):
    d = start
    while d != os.path.dirname(d):
        if os.path.exists(os.path.join(d, "pubspec.yaml")):
            return d
        d = os.path.dirname(d)
    raise SystemExit("Could not locate repo root (pubspec.yaml) above " + start)


# ARBs live in <repo>/lib/l10n; this script may live at any depth under scripts/.
L10N = os.path.join(_repo_root(SCRIPT_DIR), "lib", "l10n")
en = json.load(open(os.path.join(L10N, "app_en.arb"), encoding="utf-8"))
hi = json.load(open(os.path.join(L10N, "app_hi.arb"), encoding="utf-8"))

LANG_FIELDS = ["hindi", "marathi", "bengali", "punjabi",
               "tamil", "telgu", "malyalam", "kannada"]

rows = []
for k, v in en.items():
    if k.startswith("@"):
        continue
    if k in hi:
        continue
    row = {"key": k, "english": v}
    for f in LANG_FIELDS:
        row[f] = ""
    rows.append(row)

out = os.path.join(SCRIPT_DIR, "TRANSLATIONS_TODO.json")
with open(out, "w", encoding="utf-8") as f:
    json.dump(rows, f, ensure_ascii=False, indent=2)
    f.write("\n")

print(f"Wrote {len(rows)} untranslated keys -> {out}")
