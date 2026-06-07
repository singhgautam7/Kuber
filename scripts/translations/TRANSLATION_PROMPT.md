# Kuber — Translation task (hand to any LLM)

You are translating UI strings for **Kuber**, a personal expense-manager app
(plain, friendly, everyday Indian-English tone). Translate the English UI strings
in the attached `TRANSLATIONS_TODO.json` into **8 Indian languages**.

> This file may contain the strings for **all remaining app modules at once**, so
> it can be large. If it is too big for one response, translate it in chunks — but
> each chunk must keep the **exact same array structure** (same objects, same
> `key`/`english`, only the language columns filled). Never drop, reorder, merge,
> or renumber objects. Concatenating your chunks must reproduce the full array.

## Input / output format

The file is a JSON array. Each object looks like:

```json
{
  "key": "noLedgerEntries",
  "english": "No ledger entries yet",
  "hindi": "", "marathi": "", "bengali": "", "punjabi": "",
  "tamil": "", "telgu": "", "malyalam": "", "kannada": ""
}
```

- Fill **every** empty language field with the translation of `"english"`.
- **Do NOT change** `"key"` or `"english"`.
- Return the **same JSON array**, same order, valid JSON, nothing else.

Language columns map to: hindi=हिन्दी, marathi=मराठी, bengali=বাংলা,
punjabi=ਪੰਜਾਬੀ, tamil=தமிழ், telgu=తెలుగు (Telugu), malyalam=മലയാളം (Malayalam),
kannada=ಕನ್ನಡ.

## Hard rules (must follow exactly)

1. **Preserve placeholders verbatim.** Tokens like `{person}`, `{count}`,
   `{date}`, `{details}`, `{pct}`, `{amount}` must appear **unchanged** in the
   translation. Do not translate or reorder the braces' contents.
2. **Preserve ICU plurals.** If a string contains
   `{count, plural, =1{...} other{...}}`, keep that exact structure; translate
   only the human text inside each `{...}` branch, keep `=1`, `other`, `{count}`.
3. **Keep `\n`** (newline) wherever it appears, in the same position.
4. **No em dashes (—).** If the English uses a middot `·`, keep the `·`.
5. **Numbers stay Western digits** (1, 2, 3 — never १/੧/১/௧). Do not localize digits.
6. Keep the brand word **"Kuber"** as-is. Keep example tokens like `HDFC`,
   `DD/MM/YYYY`, `PDF`, `₹`, and `%` as-is.
7. Keep ALL-CAPS section labels short (they are headers/eyebrows). Casing may be
   dropped for scripts without case (most of these), that's fine.
8. Natural, concise phrasing a real speaker would use in an app — not literal
   word-for-word. Verb position correct per language.

## Then what

Return the filled JSON. The maintainer runs
`python3 scripts/translations/apply_translations.py <filled.json>` which merges each
translation into the matching `app_<code>.arb` file by `key`. Re-runnable and
order-independent; partially-filled files merge what's present.
