# Kuber — Localization WIRING continuation prompt

Hand this to any capable coding LLM with repo access. It explains how to (A) apply
a translated JSON, and (B) continue extracting + wiring user-facing strings to the
localization system, exactly the way the rest of the app was done.

---

## 0. Project

Kuber — local-first Flutter expense manager (Android + Web). Stack: Flutter,
Riverpod, Isar, GoRouter, fl_chart, google_fonts. Design language "Vault":
fixed dark+light palettes, border-based separation (no shadows), 8dp radius,
Inter + Noto-Sans regional fonts. Branch: `new/lang-support`.

Toolchain note (macOS): the Flutter SDK lives at `~/Documents/SDK/flutter/bin/`.
Use `~/Documents/SDK/flutter/bin/flutter <cmd>`. Needs Full Disk Access granted to
the terminal/agent.

## 1. i18n architecture (already set up — do not rebuild)

- **9 locales**: en (template/default), hi, mr, bn, pa, ta, te, ml, kn.
- ARB files: `lib/l10n/app_<code>.arb`. `app_en.arb` is the template and is the
  single source of truth for keys + `@key` placeholder metadata.
- `l10n.yaml`: arb-dir `lib/l10n`, template `app_en.arb`, output
  `app_localizations.dart`. Generated classes are in `lib/l10n/app_localizations*.dart`.
- Regenerate after ANY ARB change:
  `~/Documents/SDK/flutter/bin/flutter gen-l10n`
- **English fallback is intentional**: a key present only in `app_en.arb` makes
  gen-l10n emit it in every locale class with the English value (prints a harmless
  "N untranslated" notice). So you can add English keys, wire code, ship, and
  translate later. This is the "English-first" workflow.

### Access patterns
- **Widgets (have BuildContext):** `context.l10n.keyName`
  via `import 'package:kuber/core/utils/l10n_ext.dart';`
  (defines `extension L10nX on BuildContext { AppLocalizations get l10n => AppLocalizations.of(this)!; }`)
- **Services / providers / isolates (no context):**
  `lookupAppLocalizations(AppLocale.current).keyName`
  (`AppLocale.current` is the global active locale in `lib/core/utils/locale_font.dart`).
- **Parameterized:** `context.l10n.key(arg)` — placeholders declared as `@key`
  metadata in `app_en.arb`. ICU plurals use `{count, plural, =1{...} other{...}}`
  with `"count": {"type": "int"}`.

### Typography
- Never call `GoogleFonts.*` directly in a widget. Use `localeFont(...)` from
  `lib/core/utils/locale_font.dart` (it already maps every script incl.
  Tamil/Telugu/Kannada/Malayalam to the right Noto font + line-height). When you
  only change a string and the existing style already uses `localeFont` or
  `Theme.of(context).textTheme`, leave the style alone.

## 2. The translation pipeline (scripts in `lib/l10n/`)

- `merge_arb.py` — append English-only keys to `app_en.arb`.
  `python3 lib/l10n/merge_arb.py lib/l10n <patch.json>` where patch is
  `{"en": { "keyName": "English text", "@keyName": {"placeholders": {...}} }}`.
  Raises on duplicate keys (check existing keys first — reuse them!).
- `gen_translations_json.py` — writes `TRANSLATIONS_TODO.json` = every key in
  `app_en.arb` missing from `app_hi.arb` (i.e. English-only). This is the file the
  user translates. `python3 lib/l10n/gen_translations_json.py`
- `apply_translations.py` — merges a filled translations file back into all 8
  non-English ARBs by `key`. `python3 lib/l10n/apply_translations.py <filled.json>`
  Re-runnable; skips keys already present; ignores empty cells.
- `TRANSLATION_PROMPT.md` — the prompt to hand a translation LLM.

### The full translation hand-off loop (how the human is involved)
The human does the translating in a separate LLM; you only produce + apply files.
Per batch:
1. **You wire** a feature English-first (add English keys via `merge_arb.py`, wire
   call sites) so the build stays green.
2. **You generate the to-translate file:** `python3 lib/l10n/gen_translations_json.py`
   → writes `lib/l10n/TRANSLATIONS_TODO.json` (every key still English-only).
3. **You hand the human two things:** the path to `TRANSLATIONS_TODO.json` and the
   path to `TRANSLATION_PROMPT.md`. Tell them: "paste `TRANSLATION_PROMPT.md` into
   any LLM, attach `TRANSLATIONS_TODO.json`, and return the filled file." They will
   give back a JSON array with the 8 language columns filled (key + english
   unchanged). They may rename it (e.g. `TRANSLATIONS_DONE.json`) and place it in
   `~/Downloads/`.
4. **You apply what they return:**
   - `python3 lib/l10n/apply_translations.py /path/to/their_filled.json`
   - `~/Documents/SDK/flutter/bin/flutter gen-l10n`
   - `~/Documents/SDK/flutter/bin/flutter analyze` → expect only the 7 known
     pre-existing `about_screen.dart` / `about_l10n.dart` infos (interpolation /
     escape lints — NOT from this work).
   - Verify a sample landed: `grep "get <someKey>" lib/l10n/app_localizations_hi.dart`
5. Commit the batch (see §6) and move to the next feature.

The loop is order-independent and resumable: `apply_translations.py` skips keys
already present and ignores empty cells, so partial returns and multiple rounds
compose cleanly. `gen_translations_json.py` always re-emits the *complete*
outstanding set, so the human can also choose to translate everything in one go
near the end.

NOTE: `gen_translations_json.py` only finds keys MISSING from `app_hi.arb`. It does
NOT catch a key that exists in the non-English ARBs but whose value is still
English (a placeholder). As of this writing there are none (verified: the only
`hi == en` key is `sipAmountPrefix: "SIP {amount}"`, which is correct since "SIP"
+ a number stay as-is). If you ever suspect English placeholders, scan for
`hi[k] == en[k]` with a Latin letter and eyeball the result.

## 3. Per-string wiring procedure (repeat per file)

1. Find hardcoded user-facing literals: `Text('...')`, `label:/title:/subtitle:/
   hintText:/actionLabel:/actionTooltip: '...'`, `'...'` in dialogs/snackbars.
2. **Reuse existing keys** when the English matches (check `app_en.arb` first to
   avoid duplicate-key errors and key bloat). Common reusable keys already exist:
   `cancelLabel, deleteLabel, editLabel, saveChanges, accountTitle, accountUpper,
   amountUpper, dateUpper, notesLabel, selectAccountTitle, selectCategoryTitle,
   categoryLabel, schedule, identity, typeLabel, errorWithDetails, okLabel`, etc.
3. For genuinely new strings, add them English-only via a `merge_arb.py` patch.
   Use descriptive camelCase keys (e.g. `noRecurring`, `frequencyLabel`).
4. `flutter gen-l10n`.
5. Replace literals with `context.l10n.key` (widgets) or
   `lookupAppLocalizations(AppLocale.current).key` (no-context).
6. Add `import 'package:kuber/core/utils/l10n_ext.dart';` to the file if missing.
7. **De-const**: replacing a literal inside a `const` widget/list requires
   removing `const` (e.g. `const KuberFieldLabel('X')` → `KuberFieldLabel(context.l10n.x)`;
   `const [...]` segment/chip lists → drop `const`).
8. `flutter analyze <path>` for that file → fix until clean.

### Hard rules (must honor)
- No new packages. No Isar schema changes. No Vault design changes. No perf
  regressions.
- **No em dashes (—) in user-facing strings.** Middot `·` is fine.
- **Numbers stay Western digits** (1,2,3). Currency symbols (₹) and the brand
  word "Kuber" stay as-is.
- **Do NOT localize user-entered data** (account/category/tag/transaction/person
  names, notes) — only chrome/labels.
- **Do NOT localize strings used as identifiers / match keys / map keys.**
  Known cases to leave English:
  - `lib/features/ledger/providers/ledger_provider.dart` — `'Lent to {name}'` /
    `'Borrowed from {name}'` are stored as the txn name AND matched via
    `.startsWith('lent to')` / `'borrowed from'`. Leave English.
  - `lib/features/investments/screens/investments_screen.dart` — `_assetLabel()`
    returns English used by `_assetColor()` (color map) + allocation grouping.
    Keep it English; localize only DISPLAY via the separate `_assetDisplay()`.
  - System category matches like `c.name == 'Investment'` / `'Lent / Borrow'`.
  - Standalone `'—'` no-value placeholders (glyph, not copy) — leave as is.
- Static methods that return labels: convert to instance methods so they can use
  `context.l10n` (see `_typeLabelLocalized` in investment_detail_sheet.dart), or
  inline the switch at the call site.
- For uppercase section labels where English is ALL-CAPS, you may store the key
  title-case and call `.toUpperCase()` at the call site (no-op for Indic scripts),
  OR store the all-caps English directly. Be consistent within a file.

## 4. Status (as of this handoff)

`app_en.arb` ≈ 1108 keys. `flutter analyze` clean except 7 known pre-existing
`about_screen`/`about_l10n` infos. A full debug APK builds green. Every key in
`app_hi.arb` is fully translated (only `sipAmountPrefix` is intentionally `hi==en`).

Each item below is tagged with what it needs:
- **[REBUILD-ONLY]** = already wired AND translated in source/ARB/generated. If it
  shows English on a device, that's a STALE BUILD. Do NOT re-wire or re-translate.
  Tell the user: `flutter clean && flutter pub get && flutter run` (uninstall the
  app first if Android cached old assets).
- **[WIRE]** = code still has hardcoded English; replace with `context.l10n.*`
  (English-first), then it enters the translate loop.
- **[TRANSLATE]** = already wired; the new keys just need values (they appear in
  `TRANSLATIONS_TODO.json` after you `gen_translations_json.py`).
- **[BOTH]** = needs wiring now, and the new keys then need translating.

### Already done — [REBUILD-ONLY] (the user kept reporting these as "not translated"; they're stale build)
- Bottom nav tab labels (`kuber_nav_bar.dart` / `app_scaffold.dart`).
- FAB long-press speed-dial (Lend/Loan/Investment/Recurring) — `app_scaffold.dart`.
- Analytics date quick-filters (TODAY/THIS WEEK/…) — `quick_filter_chips_row.dart`.
- More tab — BOTH layouts: `more_screen.dart` (simple) and `more_screen_modern.dart`
  (modern). All menu buttons (Accounts/Categories/Settings/…) use `context.l10n.menu*`
  and are translated. Tab title = `navMore`.
- More search (`more_search_screen.dart`) — chrome via `context.l10n`; the
  calculator/tool entries via `tL10n()` → `tools_l10n.dart` (38 entries, all 9 langs).
- About screen (`about_screen.dart`, `widgets/about_sections.dart`, `_MadeInIndiaFooter`
  incl. "Made with ♥ in India") — uses its OWN map: `abL10n(...)` / `aboutL10n` in
  `lib/core/constants/about_l10n.dart`, already translated in all 9 languages.
  **Do NOT move About strings into the ARB.**
- Already fully done in earlier batches: accounts, budgets, loans, ledger,
  investments, recurring, dashboard/home (core), history (core), analytics+charts,
  transactions/add-transaction (core), onboarding (core), settings (core screen),
  insights, **categories**, **tags**, **export** (UI), and **stories** —
  bubbles (`story_ring._localizeBubbleLabel` → `bubble*` keys), archive screen,
  and generation are all done.
  NOTE: the "Money Stories" / "Balance Card" / etc. titles are **widget-catalog
  names** in `lib/features/widget_editor/data/widget_catalog.dart` (a `const`
  list). They render in the widget-editor screen. Localize the whole catalog in
  the `widget_editor` batch (resolve `name` via l10n at the display sites; keep a
  stable `id`). `export_provider.dart` (CSV/PDF file content + native save dialog)
  is intentionally English for document portability.

### Remaining work — [WIRE] / [BOTH]  (counts are wired/total; all are [BOTH] unless noted)
- `tags` — `more/screens/tags_screen.dart` + `features/tags/*` widgets (NOT tag
  names typed by the user).
- `more` leftovers — `how_to_use_screen.dart`, `ask_kuber_screen.dart`,
  `charts_screen.dart`, and leftover literals in `feedback_screen.dart`
  (Bug / New Feature Request / General Feedback chips), `permissions_screen.dart`.
- `tools` 1/28 — calculators hub + ~12 calculators + calculator widgets + bill
  splitter (4 files) + split calculator. Large but mechanical. NOTE: tool *names*
  may already be in `tools_l10n.dart` (`tL10n`); the per-calculator field labels /
  results are the hardcoded part to WIRE into the ARB.
- `transactions` 12/23 — remaining info/help sheets, view sheets, and the
  account-type label shown in the transaction row.
- `shared` 5/31 — empty state, form widgets, date range, info/WIP sheets, app
  scaffold extras, pickers, preview row, `kuber_info_bottom_sheet` content.
- `settings` 6/13 — data management screen + data action/export/import widgets,
  remaining choice sheets.
- `backups` 0/7 — automatic backups screen + widgets.
- `notifications` 1/5 — [BOTH, no-context] notifications sheet + `notification_service.dart`
  OS bodies + per-type processors (ledger/budget/recurring reminders). These run
  without a BuildContext → use `lookupAppLocalizations(AppLocale.current).key`,
  NOT `context.l10n`. Same for `recurring/data/recurring_processor.dart`,
  `ledger/data/ledger_reminder_processor.dart`, and the budget service reminders.
- `tutorial` 0/9, `auth` 0/2, `splash` 0/1, `widget_editor` 0/6.

**INTENTIONALLY ENGLISH (do not touch):** `lib/features/dev/*` (developer-only
screens); the feedback email body template (sent to the developer); ledger
`'Lent to {name}'` / `'Borrowed from {name}'` stored txn names; investment
`_assetLabel` color-map keys; `DateFormat` month/day names (unless that screen
already inits locale date symbols).

## 5. Loop to finish the job
For each remaining [WIRE]/[BOTH] feature: scope strings → reuse/add keys via
`merge_arb.py` → `gen-l10n` → wire call sites → `flutter analyze` clean → commit
(§6) → `gen_translations_json.py` → hand the user `TRANSLATIONS_TODO.json` +
`TRANSLATION_PROMPT.md` → apply what they return (§2). Recommended order:
tags → export → stories bubbles → more leftovers → tools → transactions/shared →
settings/backups → notifications → tutorial/auth/splash/widget_editor. Finish with
`flutter analyze` (only the 7 known infos) and `flutter test`.

## 6. Commit each batch
The user wants the `new/lang-support` branch updated per batch. After each feature
is wired + analyze-clean:
```
cd "<repo>"
git add -A
git commit -m "i18n: localize <feature> (English-first)

Co-Authored-By: Claude Opus 4.8 <noreply@anthropic.com>"
```
Do not push unless asked. Keep the ARB helper scripts + `TRANSLATIONS_TODO.json`
in the commit so the human always has the latest to-translate file.
