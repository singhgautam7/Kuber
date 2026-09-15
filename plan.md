# Plan — four fixes (Analytics header, Tools title, CLAUDE.md, cold-start jank)

Status legend: `[ ]` planned, `[x]` done, `[?]` waiting on confirmation.

---

## Bug 1 — Analytics title misaligned `[x]` (verified on device, Obsidian + Alabaster)

### Finding
`KuberPageHeader` (`lib/shared/widgets/kuber_page_header.dart:30`) already pads
itself `EdgeInsets.fromLTRB(20, 8, 20, 24)`. Every screen in the app renders it as a
bare `SliverToBoxAdapter` / child, *except* Analytics.

- History (`transaction_list_screen.dart:102`): `SliverToBoxAdapter(child: KuberPageHeader(...))`
  → title at 20 px; filter row / summary / cards at `KuberSpacing.lg` (16 px).
- Analytics (`analytics_screen.dart:329-343`): header **and** `TopFilterRow` nested in
  `SliverPadding(horizontal: KuberSpacing.lg)` → title at 16 + 20 = **36 px**, body at 16 px.
  `advanced_analytics_landing.dart:47` even has a comment warning about exactly this.

### Change
`analytics_screen.dart` only: move `KuberPageHeader` out of the `SliverPadding` into its
own `SliverToBoxAdapter` (identical to History). `TopFilterRow` has no padding of its own,
so it stays inside a `SliverPadding(lg)` like History's filter row. No component changes,
no magic numbers.

---

## Bug 2 — Tools hub titled "Signature" `[x]` (verified on device, Obsidian + Alabaster)

### Finding
`tools_hub_screen.dart:72` renders `context.l10n.moreToolsTitle`. That key is the
**More-tab section header** (`app_en.arb:1472`), renamed "More" → "Signature" in
`29671fb`. Only two consumers: `more_content.dart:144` (correct) and the Tools hub (wrong).

Siblings checked, all pass their own titles, none reuse the key:
Ask Kuber (KuberAppBar), SMS Import `'Import from\nSMS'`, Kuber Notes `'Kuber Notes'`,
Kuber Cards `'Kuber Cards'`, Quick Add `'Quick Add'`.

### Change
`tools_hub_screen.dart:72` → `context.l10n.menuCalculators` ("Calculators & Tools",
already translated in all 9 ARBs, it's the More-tab tile label for this page). No ARB edits.

---

## Bug 3 — CLAUDE.md `[x]` (note: `.gitignore:50` ignores `/CLAUDE.md`; un-ignore if it should ship)

Existing `CLAUDE.md` is short and Vault-correct but missing: product positioning, shared
component inventory, feature map / Pro model, spec locations, hard rules the brief lists.
Rewrite in place (scannable sections, reference specs by path, no spec duplication).

Facts verified from the repo, not invented:
- Commands: `flutter run`, `flutter run -d chrome`, `flutter build apk`, `flutter test`,
  `flutter analyze`, `dart run build_runner build`, `flutter gen-l10n` (l10n.yaml present),
  `flutter run --dart-define=KUBER_UNLOCK_PRO=true` (from `specs/pro-gating-enabled.md`).
- Shared components that actually exist: `KuberAppBar`, `KuberPageHeader`, `AppButton`
  (there is no `KuberButton` class), `KuberBottomSheet`, `InfoTable`, `SheetButtonSection`,
  `KuberInfoBottomSheet` + `KuberInfoConfig`, `showKuberSnackBar`, `KuberEmptyState`,
  `KuberSkeleton`. `enableSnap` does not exist in the codebase; not documented.

---

## Bug 4 — Cold-start / SMS-import jank `[x]` diagnosed, fixed, re-measured

### Architecture (what actually runs, from code reading)

**Before `runApp` (native splash showing, no custom splash yet)** — `main.dart:_bootstrap`:
Isar open → seed → migrations → `ensureEntitlementBootstrap` → SharedPreferences →
`NotificationService.init` → `RecurringProcessor.processAll()` → backup-due query →
`maybeSeedWelcomeStory`. All awaited on the main isolate. This delays time-to-first-frame
but **cannot stutter the custom splash** (it hasn't been built yet).

**Custom splash** = `ColdStartSplash` overlay (`cold_start_splash.dart`), 400 ms fade+rise
entrance, 900 ms hold, 320 ms fade-out. It is painted **on top of Home**, which is built
from frame 1. So splash stutter == anything that blocks the UI thread in the first
~1.6 s: Home's first build + provider hydration + the on-open batch.

**First post-frame callback** (`app.dart:63-82`) on a normal cold start fires
`_runOnOpenBatch()` **immediately** — 9 concurrent tasks during the splash entrance:
budget check, ledger reminders, due backup, SMS cleanup, reminder maintenance,
credit-card reminders, **widget sync (loads ALL transactions + categories)**, purchase init
(Play Billing connect + `queryPurchases`), promo config (HTTP). Then tab pre-warm at +1.5 s.
The code comment at `main.dart:34` already acknowledges this batch "saturates the main
thread" — the loader path was fixed, the plain Home path was not.

**Also in frame 1's post-frame** — `SmsImportHomeWidget` (`sms_import_home_widget.dart:29`)
starts a background SMS scan if last scan > 30 min ago (true on every first-of-day open):
platform-thread inbox read + `Isolate.spawn`.

**Home hydration** — `transactionListProvider` = `isar.transactions.where()...findAll()`
(async, but Isar deserialises 6000 objects on the main isolate when the future resolves),
then `monthlySummaryProvider`, `homeIncomeExpenseProvider`, `homeWidgetsProvider`, etc.
derive from it synchronously.

**SMS Import page, first open**:
1. `readInbox` (`MainActivity.kt:305`) runs the ContentResolver query, builds
   `List<Map>` and the StandardMessageCodec encode **synchronously on the Android
   platform thread**. On Android, Flutter's vsync comes from Choreographer on that thread,
   so blocking it freezes frames even though the Dart UI isolate is idle. Dart-side decode
   of N maps then lands on the UI isolate. This is my prime suspect for the SMS page.
2. `SmsScanController.run` copies the whole raw list into a new isolate (main-isolate cost
   proportional to inbox size).
3. Regex parse is already off-thread (`sms_scan_runner.dart`) — not a suspect.
4. `GoogleFonts.jetBrainsMono` in the list rows (`sms_import_widgets.dart:332`,
   `sms_badge.dart:70`) is **not bundled** (only Inter is). First use = cache-file read +
   main-isolate font parse + relayout of every visible row. Classic "first open only" jank.
5. `_toStagingRows` does one Isar `getForSender` per parsed message (async N+1; not a
   frame blocker, noted only).

### STEP A — measurement plan (to run next, before any fix)
Device: OnePlus CPH2723 (6000+ txns) via `~/Library/Android/sdk/platform-tools/adb`.
1. `flutter run --profile --trace-startup -d 3be442` → `build/start_up_info.json`
   (engine init / first frame / first useful frame).
2. Temporary `SchedulerBinding.addTimingsCallback` logging frames > 16.7 ms with a
   `KUBER_JANK` prefix + `Timeline.startSync` markers around each `_runOnOpenBatch` item,
   Home first build, `transactionListProvider` resolve, `readRawInbox`, `Isolate.spawn`,
   font load. All removed before finishing.
3. Cold start = `adb shell am force-stop com.grs.kuber` then launch. Capture 3 runs.
4. SMS page: cold start, wait for idle, open Import from SMS, capture the same log.
5. Results table (before) goes in the section below; after-fix table added post-fix.

### STEP A results — BEFORE (measured 2026-09-15, OnePlus CPH2723, 120 Hz, profile build, 5,899 txns)

Method: temporary `lib/core/utils/perf_probe.dart` (process-clock probes, frame timings
> 12 ms with `vsyncOverhead`, and a 2 ms timer that logs any UI-isolate stall > 12 ms).
Cold start = `am force-stop` then `am start -W`. 5 runs; run 4 shown, others consistent.

**Cold start timeline (ms from `main()`)**

| t | event |
|---|---|
| 0 → 49 | `_bootstrap` total: Isar open 36, seed 6, migrations/entitlement/prefs/notifications/recurring/welcome 7. **Not a problem.** |
| 49 | `runApp()`; `am start` TotalTime 450–585 ms, so ~430 ms is native process + engine init (native splash, untouchable) |
| 55 | first frame; `_runOnOpenBatch` fires all 9 tasks; Home `SmsImportHomeWidget` also fires (scan gated to >30 min since last) |
| 67 → 82 | widget sync re-loads all 5,899 txns (2nd full load); `transactionListProvider.getAll` 90 → 98 (8 ms, async) |
| 55 → 155 | **frame#1: 100 ms, raster 65 ms** (20–111 across runs). First raster of Home under the opaque splash = Impeller/Vulkan pipeline + first paint. Raster thread, not Dart. |
| 60 → 270 | **frame#2: 118 ms, build 3.6 ms, raster 11 ms**: queued behind frame#1's raster. Same root as frame#1. |
| 172 → 365 | Home rebuilds every ~15 ms (progressive-reveal ramp) hidden under the splash; builds 0–8 ms each; frames #9/#12 at 14/19 ms |
| **236 → 267** | **UI isolate blocked 31 ms inside `_syncCharts`** (widget sync; 6 `_bucket` passes with per-txn `DateTime` allocation + 5 PNG renders). Lands mid splash entrance (entrance = 55 → 455). → frame#8 22 ms, `vsyncWait 18.5` |
| 255 → 276 | (run 1 only, scan due) `readRawInbox` 21 ms on the **platform thread** even for an incremental query returning 0 msgs; `Isolate.spawn` 4 ms. Run 1 had extra frames #8 37 ms and #11 23 ms vs runs without the scan |
| 1556 | `_warmTabProviders` → **UI isolate blocked 25 ms** (analytics O(N) compute). Splash fade-out runs 1355 → 1675, so this lands in the middle of the fade. |
| 1673 | splash `onFinished` → frame#37 15 ms (`vsyncWait 14.4`, overlay removal + Home reveal) |

Jank frames in the splash window (55 → 1675 ms): 5–7 per run (2 unavoidable first-raster,
1 from `_syncCharts`, 1–2 from the reveal ramp, 1 from warm-up, +2 when the SMS scan runs).

**Not the cause (ruled out):** Isar open/migrations (36 ms, before any UI), sync Isar
reads (none on transactions), `getAll` deserialisation (8 ms async, no stall logged),
purchases/promo/backup/reminder tasks (all < 10 ms, no stalls), Home first build (2–3 ms).

**Side finding:** `didChangeAppLifecycleState(resumed)` runs a full widget sync on *every*
resume; measured 3 × 13–15 ms stalls + `accountBalances` 52 ms wall when a deep link
resumed the app. Same root as `_syncCharts` above.

**SMS Import, true first open in a session** (cold start → idle → tap More → Import from SMS;
provider cold, no scan due):

| t (ms) | event |
|---|---|
| 0 | `initState`; +3 first frame; +7 `smsImportProvider` build (3 `getByStatus` reads + prefs + permission) |
| +15 → +28 | UI isolate stall 13 ms |
| +52 → +77 | **UI isolate stall 25 ms** |
| frames #157–161 | **31 / 25 / 44 / 20 / 18 ms** (#159 build = 24 ms) — the visible stutter |

Cause: `GoogleFonts.jetBrainsMono` (3 weights: regular/500/600, confirmed present in the
app's runtime font cache `files/JetBrainsMono_*.ttf`) is loaded on first use each session:
file read → `loadFontFromList` parse on the UI thread → `fontsChange` → full relayout of
the route stack (the 24 ms build). A warm re-open of the same page in the same process
showed a single 20 ms frame and no stalls, which isolates the cost to first-use font
loading. The inbox scan / regex parse is **not** on this path (already on a worker isolate).

### STEP B — fixes implemented (only confirmed blockers)

| # | Confirmed by | Fix | User-visible change |
|---|---|---|---|
| B1 | 31 ms `_syncCharts` stall + SMS scan at 255 ms, both inside the splash entrance | Gate `_runOnOpenBatch` on the splash's `onFinished` (reuse `onOpenBatchReadyProvider`, exactly the loader path's pattern). Loader path unchanged. | Widgets / backup / entitlement refresh start ~1.6 s later. Nothing visible. |
| B2 | 25 ms warm-up stall inside the splash fade-out | Start the 1.5 s warm-up timer from splash `onFinished` instead of first frame (it is already part of the batch, so B1 covers it) | Analytics/History warm ~1.6 s later; still before a human reaches the tab |
| B3 | `SmsImportHomeWidget` scan during the splash | Same gate: the widget waits for `onOpenBatchReadyProvider` before `_maybeBackgroundScan` | "Last checked" on the Home SMS card updates ~1.6 s later |
| B4 | `readInbox` 21 ms on the platform thread (blocks Choreographer/vsync) | `MainActivity.readInbox`: run the cursor loop on a background thread, post `result.success` on the main looper. ~10 lines Kotlin, no Dart change | None |
| B5 | SMS page 25 ms stall + 24 ms relayout from runtime font load | Declare JetBrains Mono (Regular/Medium/SemiBold, Latin subset like Inter) in pubspec `fonts:` and switch the 7 `GoogleFonts.jetBrainsMono(...)` call sites to `fontFamily: 'JetBrainsMono'`. Engine-registered fonts never trigger `fontsChange`, so no relayout and no first-use parse on the UI thread. Size: ~3 × 40 KB subset (~120 KB) vs 17 MB budget. Alternative with zero call-site change is dropping the TTFs into `assets/google_fonts/`, but that only removes the file read, not the parse + relayout, so I recommend the pubspec route | Mono text renders correctly on the very first frame instead of snapping in after the font loads |
| B6 (optional) | `_syncCharts` 31 ms of sync CPU (also hits every resume) | Pre-extract `(dayOffset, isIncome, amount)` once per sync so the 6 `_bucket` passes are int math instead of 6 × 5,899 `DateTime` allocations. Small, contained in `widget_sync_service.dart` | None |

Not fixing: frames #1/#2 (first raster, Impeller already active; only a shader-warmup
bundle could help and that is out of scope), the Home reveal ramp under the splash (design
choice: Home is settled when the splash lifts), `getAll` deserialisation (8 ms, async).

### STEP A results — AFTER (same device, same method, 5 cold starts + 1 first SMS open)

**Cold start, splash window (first frame → splash finished, ~55 → 1690 ms)**

| Metric | BEFORE | AFTER |
|---|---|---|
| UI-isolate stalls > 12 ms inside the splash | 31 ms (`_syncCharts`) at 236 ms; 25 ms (warm-up) at 1564 ms; +21 ms platform-thread inbox read when a scan was due | **none** (one 14–19 ms right after `getAll` resolves = Isar deserialisation of 5,899 rows, unchanged) |
| Frames > 16.7 ms inside the splash | 5–7 per run | 2 on a truly cold process (first raster, 34–46 ms), **0** on runs 2–5 (worst frame 15.1 ms) |
| `_syncCharts` wall time | 132 ms with a 31 ms sync block | 44–57 ms, no block |
| Warm-up stall | 25 ms, inside the fade-out | ≤19 ms (run 4), below 12 ms (run 5), at 3.2 s on idle Home |
| Widget sync second full-table load | 15–19 ms deserialisation per sync | removed (reuses `transactionListProvider`) |
| `am start` TotalTime | 449–585 ms | 386–474 ms |

Remaining frames inside the splash are the Home reveal-ramp frames at 12–15 ms (1.5 frames
at 120 Hz, all under the 16.7 ms bar) and the first-raster frame on a cold process.

**SMS Import, true first open in a session**

| Metric | BEFORE | AFTER |
|---|---|---|
| UI-isolate stalls | 13 ms + **25 ms** (font parse) | 13 ms (provider's 3 Isar reads) |
| Frames > 12 ms | 31 / 25 / **44** / 20 / 18 ms (5 frames, 24 ms relayout build) | 29 / 18 / 16 / 12 ms (route push first build + raster; no relayout) |
| Mono text | snaps in after font load | correct on first frame |

The remaining 29 ms is the route's own first build + raster of the header and cards, the
same shape as any pushed screen. `readInbox` now runs on a background executor; it was
not exercised in the AFTER run (no scan due), verified by code + build only.

**Other:** every app resume ran a full widget sync with a second full-table load; that
load is gone and the chart pass is 4× cheaper, so resume hitches shrink too (not
re-measured).

**Size:** arm64 release APK 17.19 MB; the three bundled JetBrains Mono weights are
~100 KB compressed of that. HEAD cannot be built on this SDK for a true baseline.


## Files changed

Bug 1
- `lib/features/analytics/screens/analytics_screen.dart` — header moved out of the horizontal `SliverPadding` (History structure)

Bug 2
- `lib/features/tools/tools_hub_screen.dart` — `moreToolsTitle` → `menuCalculators`

Bug 3
- `CLAUDE.md` — rewritten (product, stack, specs, commands, hard rules, component inventory, feature map, layout, performance rules). Note: `.gitignore:50` ignores `/CLAUDE.md`
- `specs/performance.md` — §6 rewritten for the splash-gated batch; new §6b (fonts, platform channels, per-group loops)

Bug 4
- `lib/main.dart` — `onOpenBatchReadyProvider` doc now means "app interactive"; OFL license registration for the bundled font
- `lib/app.dart` — on-open batch gated on splash `onFinished` + loader hand-off (`_maybeRunOnOpenBatch`); warm-up rides on the batch
- `lib/features/sms_import/widgets/sms_import_home_widget.dart` — background scan waits for `onOpenBatchReadyProvider`
- `android/app/src/main/kotlin/com/grs/kuber/MainActivity.kt` — `readInbox` on a single-thread executor, result posted to the main looper; executor shut down in `onDestroy`
- `lib/core/services/widget_sync_service.dart` — reuse `transactionListProvider` instead of a second `findAll`; `_syncCharts` pre-filters to the last 6 months; two `return await` fixes for the SDK's new `unawaited_return_in_try_block` lint
- `lib/core/utils/date_formatter.dart` — `groupHeader` caches `DateFormat` + l10n per locale
- `lib/features/history/utils/history_utils.dart` — int day key instead of ISO string round-trip
- `pubspec.yaml` — `fonts:` JetBrainsMono (400/500/600) + OFL asset
- `assets/fonts/JetBrainsMono-{Regular,Medium,SemiBold}.ttf` (Latin subset, same coverage as the bundled Inter), `assets/fonts/JetBrainsMono-OFL.txt`
- `lib/core/utils/locale_font.dart` — `monoFont()` helper
- 15 files: `GoogleFonts.jetBrainsMono(...)` → `monoFont(...)` (sms_import ×5, more ×4, accounts, loans, investments, dev ×2, shared transaction_detail_sheet); one dev screen `bold` → `w600`

Toolchain
- `pubspec.lock` — `flutter_quill` 11.5.0 → 11.5.1 (repo did not compile on Flutter 3.47.2; within `^11.5.0`)
- `android/gradle.properties` — two flags added by the Flutter migrator during the build (re-added on every build with this SDK)

Pre-existing, untouched: `lib/features/dev/screens/dev_tools_screen.dart` and
`lib/features/pro/debug/billing_diagnostic_sheet.dart` were already modified/untracked
in the working tree before this session.

Verification: `flutter analyze` clean apart from 5 pre-existing SDK deprecation infos in
untouched files; `flutter test` 723/723; release + profile builds succeed; Bugs 1 and 2
screenshot-verified on device in Obsidian and Alabaster.
