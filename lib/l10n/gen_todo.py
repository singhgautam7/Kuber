#!/usr/bin/env python3
"""Generate TRANSLATIONS_TODO.json — the keys that exist in the English template
(app_en.arb) but are still missing from app_hi.arb (i.e. English-only, awaiting
translation). Feed the output to a translation LLM together with TRANSLATION_PROMPT.md.

Usage (from project root):  python3 lib/l10n/gen_todo.py
"""
import json

D = "lib/l10n"
en = json.load(open(f"{D}/app_en.arb", encoding="utf-8"))
hi = json.load(open(f"{D}/app_hi.arb", encoding="utf-8"))

todo = {k: v for k, v in en.items() if not k.startswith("@") and k not in hi}
out = f"{D}/TRANSLATIONS_TODO.json"
json.dump(todo, open(out, "w", encoding="utf-8"), ensure_ascii=False, indent=2)
# Also surface which ones carry ICU placeholders/plurals (translator must preserve them).
withph = [k for k, v in todo.items() if "{" in v]
print(f"{len(todo)} keys need translation -> {out}")
if withph:
    print(f"  ({len(withph)} contain placeholders/plurals — preserve braces exactly)")
