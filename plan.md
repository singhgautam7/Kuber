# Plan — SMS Import: Pro-gated → free with 5 imports/week

Goal: SMS Import becomes fully accessible to everyone. The **import-to-transaction**
action is capped at **5 per rolling week** for free users; Pro/trial is unlimited.
Paste-a-SMS and inbox scanning/staging stay free and uncapped.

---

## Locked decisions (confirmed)

1. **Storage: SharedPreferences** (like `AskKuberUsage`), **not** Isar. No new
   `@collection`, no schema registration, no `build_runner`.
2. **Reset: anchored 7-day window** — first import stamps a reset anchor; window runs 7
   days, then re-anchors. Stored as an anchor timestamp + a count (not ISO-week buckets,
   not a per-message list).
3. **No on-screen counter** — strict mirror of Ask Kuber. The limit sheet is the only
   surfaced signal. (Item 6 dropped.)
4. **Native widget deferred** — Flutter writes an `importable` field into the widget prefs
   for forward-compat, but `SmsImportBadgeWidgetProvider.kt` caption is left unchanged for
   v1.

Sections below are updated to match these choices.

---

## 0. Important findings the brief did not anticipate (read first)

These changed the shape of the work; all now resolved by the locked decisions above.

### F1. "Mirror Ask Kuber exactly" conflicts with "new Isar collection" **[DECIDE]**
`ask_kuber/data/ask_kuber_usage.dart` does **not** use Isar and is **not** a sliding
window. It is a static class over **SharedPreferences**, keyed per **ISO calendar week**
(`ask_kuber_messages_week_YYYY-Www`). It resets on Monday automatically because a new
week reads an absent key as 0. There is no `lastResetAt`, no `currentWeekCount`, no Isar
row.

The brief instead specifies a **new Isar collection `SmsImportUsage` (id 0)** with
`lastResetAt` + `currentWeekCount`, and the testing checklist says to "backdate the reset
timestamp **via Isar**." Those two directions are mutually exclusive.

- **Recommendation: follow the brief — build the Isar collection.** It is specified in
  three places (behavior #3, the DO-NOT-CHANGE list, the testing checklist), so it is the
  clearer intent. I will interpret "mirror Ask Kuber" as *mirror the limit semantics*
  (5/week free, unlimited Pro, check-before-action, increment-after, silent for Pro), not
  the storage mechanism.
- Alternative if you'd rather truly mirror Ask Kuber: skip Isar, add a
  `sms_import_week_` SharedPreferences prefix and copy `AskKuberUsage` almost verbatim.
  Less code, no schema migration, but diverges from the brief's field spec and the
  "backdate via Isar" test step.

### F2. "Rolling / sliding window" vs the two-field schema **[DECIDE]**
A true sliding window ("imports in the last 7 days") needs a timestamp per import. The
specified fields (`lastResetAt` + a single `currentWeekCount`) can only express an
**anchored fixed window**: the first import stamps `lastResetAt = now`; the window runs 7
days from there; once `now - lastResetAt >= 7 days`, the count resets to 0 and re-anchors
on the next import.

- **Recommendation: anchored 7-day window** (matches the two fields exactly, gives a
  concrete reset date for the limit sheet: `lastResetAt + 7 days`). I'll document it as
  "rolling weekly cap," not a literal per-message sliding window.
- If you want a literal sliding window, the schema needs a `List<DateTime> importTimes`
  instead of a single count — say the word and I'll spec that instead.

### F3. Ask Kuber shows **no** on-screen counter **[DECIDE]**
The brief's item 6 says "mirror Ask Kuber's counter." Ask Kuber has **no visible
counter** — it silently blocks the 6th send. Strict mirroring = no counter, but the
testing checklist expects "counter shows 4 remaining this week."

- **Recommendation: add a small counter to the SMS Import screen** (free users only; Pro
  sees nothing or "Unlimited"), because the checklist and item 6 clearly want it. This is
  additive and low-risk. Placement below the page header, in the existing `_footer`
  muted-text style. I'll note in code that this intentionally exceeds Ask Kuber's UI.

### F4. Background scan does **not** auto-import today (simplifies item 5)
`SmsImportNotifier._runScan` only **stages** parsed rows as `unreviewed`
(`repo.insertNew`). It never creates a `Transaction`. So there is no background
auto-import to cap. "Detected/pending" == unreviewed staging, which is scanning, not
importing, and stays free per the DO-NOT-CHANGE rule ("ability to scan is different from
importing"). The cap only ever bites at the **user-initiated import** action (review
sheet / batch sheet). Item 5 is therefore satisfied by design: excess pending rows simply
remain in the Unreviewed tab. No change to `_runScan` needed.

### F5. Paste and single-list-import share one code path
Paste → `stageFromPaste` → `showSmsReviewSheet` → `_addToKuber` → `importSingle`.
List card tap → `showSmsReviewSheet` → `_addToKuber` → `importSingle`.
Batch → `importBatch`.

Paste is separate from **bulk** import (never touches `importBatch`), but it shares the
review sheet + `importSingle` with normal single imports. To keep paste free while
list-imports count, I'll thread a `countsTowardLimit` flag through
`showSmsReviewSheet` → `TransactionReviewSheet` → `importSingle` (default `true`; paste
passes `false`). Confirmed: paste is a distinct entry, so the flag cleanly separates it.

---

## 1. Where SMS Import is gated today (entry points to open up)

| # | Site | Current | Change |
|---|---|---|---|
| 1 | `sms_import/widgets/sms_import_home_widget.dart:100` `_openImport` | `if (proGate(...showSmsImportGateSheet)) push` | Remove gate; push directly. |
| 2 | `more/more_content.dart:161` | `if (proGate(...showSmsImportGateSheet)) push` | Remove gate; push directly (match Ask Kuber row above it). |
| 3 | `pro/feature_gates/gate_sheet_sms_import.dart` | `showSmsImportGateSheet` = "SMS Import is a Pro feature" entry gate | Repurpose to **limit-reached** sheet (see §5). |

No `proPill` is shown on either entry today, so nothing to remove there. Grep confirms
these are the only two `showSmsImportGateSheet` call sites.

---

## 2. New usage tracker — `lib/features/sms_import/data/sms_import_usage.dart`

A static class over **SharedPreferences**, structured like `AskKuberUsage` but with an
**anchored 7-day window** instead of ISO-week keys.

**Const:** `const smsImportFreeWeeklyLimit = 5;`

**Two SharedPreferences keys** (registered in `core/utils/prefs_keys.dart` alongside
`askKuberWeekPrefix`):
- `sms_import_window_start` — ISO-8601 string, the anchor of the current 7-day window.
- `sms_import_window_count` — int, imports counted inside the window.

**`class SmsImportUsage` (private ctor, all static):**
- `Future<int> importsThisWeek()` — read both keys; if the anchor is absent or
  `now.difference(start) >= 7d`, the effective count is **0** (window lapsed).
- `Future<int> remainingThisWeek()` — `(limit - importsThisWeek()).clamp(0, limit)`.
- `Future<bool> atWeeklyLimit()` — `importsThisWeek() >= limit`.
- `Future<DateTime?> resetDate()` — `start + 7d` when a live window exists (for the sheet
  copy); `null` when no window is active.
- `Future<void> increment(int n)` — if window lapsed/absent: set
  `sms_import_window_start = now`, `sms_import_window_count = n`. Else:
  `sms_import_window_count += n`. `n` = number actually imported (≥ 1).

No Isar, no `build_runner`, no schema registration. Fresh install has no keys ⇒ count 0 ⇒
full 5 available. To backdate for testing, edit `sms_import_window_start` in prefs (or use
Dev Tools if we add a hook — not required).

**Perf:** all reads are async and off `build` (perf.md §3). Only touched on the import
action and in the widget-sync post-frame pass — never on startup routing or scroll.
Because there is **no on-screen counter**, no `FutureProvider` for remaining is needed for
UI; the widget-sync path reads `remainingThisWeek()` directly.

---

## 3. Counting rules (one transaction = one count)

Centralize gating in `SmsImportNotifier` so both entry points share it and Pro is checked
in exactly one place (`ref.read(kuberProStateProvider).hasProAccess`).

- **Single import** (`importSingle`, gains `{bool countsTowardLimit = true}`):
  - Pro/trial → import, no count.
  - Free + `countsTowardLimit == false` (paste) → import, no count.
  - Free + counts + allowance > 0 → import, `SmsImportUsage.increment(1)`.
  - Free + counts + allowance == 0 → **do not import**; return a "blocked" outcome so the
    caller shows the limit sheet.
  - Return type becomes a small result (e.g. `SmsImportResult { imported, blocked }`) so
    `_addToKuber` knows whether to pop-success or show the sheet.
- **Batch import** (`importBatch` → `importBatchGated` semantics):
  - Pro/trial → import all, no count.
  - Free → `r = SmsImportUsage.remainingThisWeek()`; import first `min(r, N)` drafts; `SmsImportUsage.increment(min(r,N))`;
    skip the rest (they stay `unreviewed`); return `(importedCount, blockedCount)`. If
    `blockedCount > 0`, caller shows the limit sheet; a snackbar reports
    "Imported X, Y left for next week" (no em dash).
- **Skipped/duplicate/dismissed never count.** Dismiss and duplicate-skip do not call the
  counted path. Duplicates the user chooses to "Add anyway" **do** count (they become real
  transactions) — consistent with "one imported transaction = one count."

`_doImport` stays pure (no counting) so counting lives only in the two public entry
methods.

---

## 4. Import-action gating call sites

- `transaction_review_sheet.dart` `_addToKuber`: call `importSingle(..., countsTowardLimit: <fromList>)`;
  on `blocked`, `showSmsImportLimitGateSheet(context, resetDate: await SmsImportUsage.resetDate())`
  and keep the sheet open (do not pop as success). `showSmsReviewSheet` gains a
  `countsTowardLimit` param (default `true`).
- `paste_sms_sheet.dart` `_review`: opens the review sheet with `countsTowardLimit: false`.
  Paste itself (`stageFromPaste`) already only stages — no change there.
- `batch_summary_sheet.dart` `_confirm`: use the batch outcome; when `blockedCount > 0`,
  show the limit sheet + snackbar ("Imported X, Y left for next week"); still call
  `onImported()` so selection mode exits.
- The authoritative block lives in the notifier (single place); no pre-check UI is added
  (no counter).

---

## 5. Repurpose the gate sheet (`gate_sheet_sms_import.dart`)

Replace the entry-gate function with a limit-reached one, keeping the shared
`showFeatureGateSheet` shell (no new component; matches `showAskKuberLimitGateSheet`):

```dart
void showSmsImportLimitGateSheet(BuildContext context, {DateTime? resetDate}) {
  final resetLine = resetDate != null
      ? 'or wait until ${DateFormat('d MMM').format(resetDate)} for your weekly count to reset.'
      : 'or wait for your weekly count to reset.';
  showFeatureGateSheet(
    context,
    icon: Icons.sms_outlined,
    featureName: 'SMS Import',
    headline: 'Weekly SMS import limit reached',
    body:
        'Free accounts get 5 SMS imports a week. Upgrade to Kuber Pro for '
        'unlimited imports, $resetLine',
  );
}
```
- Old copy ("SMS Import is a Kuber Pro feature") is deleted; there is no entry gate now.
- Because the only former callers were the two entry points (now ungated), no dangling
  references remain. New callers are the import paths in §4.
- No em dashes; ₹/Indian formatting not needed here (no amounts).

---

## 6. Counter on the SMS Import screen — DROPPED

Strict mirror of Ask Kuber: **no on-screen counter.** The limit-reached sheet is the only
surfaced signal, exactly as Ask Kuber blocks silently on the 6th send. No new provider,
no header/footer text change.

---

## 7. Home widget badge (`SmsImportBadgeWidgetProvider`) (item 7)

**Native deferred for v1.** Flutter side — `widget_sync_service.dart` `_syncSmsBadge`:
- Keep `count` = unreviewed detected count (unchanged big number).
- Also write `importable`: for free users `SmsImportUsage.remainingThisWeek()`; for Pro
  `-1` (unlimited sentinel). This is one extra prefs read inside the already-post-frame
  sync (perf.md §6/§7) — negligible; still loads txns/categories once (perf.md §7).
- Forward-compat only: the native `.kt` caption is **not** changed now, so this field is
  written but unread until a later native pass. No `strings.xml` or `.kt` edits in this
  change.

---

## 8. Paywall comparison table (`pro_page_extras.dart`, item 8)

Change the SMS Import row (currently `free: 'Not included', pro: 'Included'`) to:
```dart
ComparisonRow(
  icon: Icons.sms_outlined,
  feature: 'SMS Import',
  free: '5 per week',      // matches the Ask Kuber row's phrasing for consistency
  pro: 'Unlimited',
),
```
Same `ComparisonRow` styling as the existing Ask Kuber row. (Brief says "5 imports per
week"; I'll use "5 per week" to match the adjacent Ask Kuber row exactly — flag if you
want the longer text.)

---

## 9. Info sheet (`InfoConstants.smsImport`, item 9)

The current info config never claims it's Pro-only, but I'll add/adjust an item to state
the limits explicitly, e.g. a new `KuberInfoItem` (icon `Icons.workspace_premium_rounded`
or reuse `lock_outline_rounded`):
- Title "5 free imports a week"
- Desc "Free accounts import up to 5 bank SMS a week. Pasting a single SMS is always
  free. Upgrade to Kuber Pro for unlimited imports."
No em dashes.

---

## 10. `specs/pro-gating-enabled.md` (item 10)

- SMS Import row in the features table:
  - Free-tier limit: `5 imports / week`
  - Gate sheet: `gate_sheet_sms_import.dart` (repurposed → limit-reached)
  - Primary check site: `sms_import/providers/sms_import_provider.dart`
    (`importSingle` / `importBatch`); limit in
    `sms_import/data/sms_import_usage.dart` (`smsImportFreeWeeklyLimit = 5`). Note entry
    points (`sms_import_home_widget.dart`, `more_content.dart`) are **no longer gated**.
  - The Ask Kuber row already reads "5 messages / week"; mirror it. Also update the
    top-line "gated features (8)" framing note if it calls SMS Import "entirely Pro".
- New "SMS Import specifics" subsection: paste-a-SMS always free; inbox scan/staging
  always free and uncapped (background staging is not importing); cap applies only to the
  review/batch import action; home widget writes an importable-within-cap field (native
  render deferred); storage/reset model (SharedPreferences anchored 7-day window, keys
  `sms_import_window_start` / `sms_import_window_count`).

---

## 11. Files touched (summary)

**New**
- `lib/features/sms_import/data/sms_import_usage.dart` (SharedPreferences static class, no `.g.dart`)

**Edited — Dart**
- `core/utils/prefs_keys.dart` — add the two SMS window keys.
- `providers/sms_import_provider.dart` — gating + counting in `importSingle`/`importBatch`, result types (reads `kuberProStateProvider`).
- `widgets/transaction_review_sheet.dart` — `countsTowardLimit`, outcome handling.
- `widgets/paste_sms_sheet.dart` — pass `countsTowardLimit: false`.
- `widgets/batch_summary_sheet.dart` — batch outcome + limit sheet/snackbar.
- `widgets/sms_import_home_widget.dart` — remove entry gate.
- `more/more_content.dart` — remove entry gate.
- `pro/feature_gates/gate_sheet_sms_import.dart` — limit-reached copy.
- `pro/paywall/pro_page_extras.dart` — comparison row.
- `core/constants/info_constants.dart` — info item.
- `core/services/widget_sync_service.dart` — write `importable` field.

No Isar schema registration, no `build_runner`, no `screens/sms_import_screen.dart`
change (counter dropped).

**Native:** none this change (deferred).

**Docs**
- `specs/pro-gating-enabled.md`

**Tests** (new): `SmsImportUsage` unit test (limit, increment, anchored 7-day reset, Pro
bypass), batch partial-allowance behavior, paste-does-not-count. Existing suite must stay
green; `flutter analyze` clean.

---

## 12. Risk vs `specs/performance.md`

- Usage reads are async SharedPreferences reads, never in `build`, only on the import
  action and in the widget-sync post-frame pass (§3, §6). No startup-routing cost.
- No counter, so no new provider and no scan-progress rebuild surface (§1, §8).
- Widget sync adds one prefs read within the existing once-per-sync run; txns and
  categories still loaded once (§7).
- No new packages. No new shared components (reuse `showFeatureGateSheet`, existing
  `KuberInfoItem`, `showKuberSnackBar`). All colors via `colorScheme`, radii via
  `KuberRadius`, Inter via `localeFont`. No hex, no shadows, no em dashes.

---

## Decisions — all resolved
1. Storage: **SharedPreferences** (not Isar).
2. Reset: **anchored 7-day window**.
3. Counter: **none** (strict Ask Kuber mirror).
4. Native widget: **deferred** (write `importable` field only).
