#!/usr/bin/env python3
"""Merge a filled TRANSLATIONS_TODO.json back into the 8 non-English ARBs.

Reads the array produced by gen_translations_json.py (after a translation LLM
has filled the language columns) and appends each key:value into the matching
ARB file, byte-preserving the existing content (textual append before the final
closing brace, same strategy as merge_arb.py).

Usage from repo root:
    python3 lib/l10n/apply_translations.py [path/to/filled.json]
Defaults to lib/l10n/TRANSLATIONS_TODO.json.

Safe to re-run: keys already present in a given ARB are skipped (not overwritten).
Rows with an empty value for a language are skipped for that language only, so a
partially-filled file still merges what it can.
"""
import json, os, sys

L10N = os.path.dirname(os.path.abspath(__file__))
src = sys.argv[1] if len(sys.argv) > 1 else os.path.join(L10N, "TRANSLATIONS_TODO.json")
rows = json.load(open(src, encoding="utf-8"))

# language column -> ARB locale code
FIELD_TO_CODE = {
    "hindi": "hi", "marathi": "mr", "bengali": "bn", "punjabi": "pa",
    "tamil": "ta", "telgu": "te", "malyalam": "ml", "kannada": "kn",
}

def esc(s: str) -> str:
    # JSON string escaping for ARB values; json.dumps gives us the quoted form.
    return json.dumps(s, ensure_ascii=False)

summary = {}
for field, code in FIELD_TO_CODE.items():
    path = os.path.join(L10N, f"app_{code}.arb")
    existing = json.load(open(path, encoding="utf-8"))
    additions = []
    for row in rows:
        key = row["key"]
        val = row.get(field, "")
        if not val:
            continue
        if key in existing:
            continue
        additions.append((key, val))
    if not additions:
        summary[code] = 0
        continue
    raw = open(path, encoding="utf-8").read()
    idx = raw.rfind("}")
    head = raw[:idx].rstrip()
    if not head.endswith("{"):
        head += ","
    block = ",\n".join(f'  {esc(k)}: {esc(v)}' for k, v in additions)
    new_raw = head + "\n" + block + "\n}\n"
    # validate
    json.loads(new_raw)
    open(path, "w", encoding="utf-8").write(new_raw)
    summary[code] = len(additions)

print("Merged keys per locale:", summary)
