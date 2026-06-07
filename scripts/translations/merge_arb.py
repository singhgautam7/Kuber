#!/usr/bin/env python3
"""Append/merge keys into Kuber ARB files with minimal diff.

Usage (from project root):
    python3 lib/l10n/merge_arb.py lib/l10n <patch.json>

patch.json shape:  { "en": {key: val, "@key": {...meta}}, "hi": {...}, ... }
- Only the language objects present are touched.
- Existing keys in a file are NOT overwritten (raises, to avoid silent dupes).
  (To re-translate an existing key, edit the ARB directly.)
- Existing file content is preserved byte-for-byte; new keys are appended before `}`.
Run `flutter gen-l10n` afterwards.
"""
import json
import sys

arb_dir = sys.argv[1]
patch = json.load(open(sys.argv[2], encoding="utf-8"))

for lang, entries in patch.items():
    if not entries:
        continue
    p = f"{arb_dir}/app_{lang}.arb"
    txt = open(p, encoding="utf-8").read().rstrip()
    existing = json.loads(txt)
    dupes = [k for k in entries if k in existing]
    if dupes:
        raise SystemExit(f"ERROR {p}: keys already exist: {dupes}")
    assert txt.endswith("}"), p
    txt = txt[:-1].rstrip()
    frag = json.dumps(entries, ensure_ascii=False, indent=2)
    inner = frag[1:-1].rstrip("\n")
    txt = txt + "," + inner + "\n}\n"
    json.loads(txt)  # validate before writing
    open(p, "w", encoding="utf-8").write(txt)
    n = len([k for k in entries if not k.startswith("@")])
    total = len([k for k in json.loads(txt) if not k.startswith("@")])
    print(f"{p}: +{n} keys (total {total})")
