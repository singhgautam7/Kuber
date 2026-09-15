# Kuber

Offline-first personal expense manager for India. No accounts, no cloud, no ads,
open source. All data lives on-device in Isar. Android is the primary target, Web second.
Design language is **Vault** (see below). App size target: under 17 MB APK.

## Stack

Flutter · Riverpod 2 (`Notifier` / `AsyncNotifier`; a few legacy `StateNotifier`s remain) ·
Isar (`isar_community`) · GoRouter · fl_chart · google_fonts (Inter, bundled in
`assets/google_fonts/`) · in_app_purchase (Play Billing) · home_widget · flutter_quill ·
flutter_local_notifications · shared_preferences.

## Specs (read before starting a feature)

| Path | What |
|---|---|
| `specs/requirments.md` | Features, data models, non-functional requirements |
| `specs/architecture.md` | Folder structure, Riverpod patterns, Isar repositories, navigation |
| `specs/design-system.md` | Vault palette (`KuberColors`), `KuberRadius`, `KuberSpacing`, component specs |
| `specs/performance.md` | **Read before touching hot files** (dashboard, analytics, history, transaction_row, widget_sync_service, ask_kuber, notes editor, sms_import). Every guarantee there must be preserved. |
| `specs/code-review/REVIEW.md`, `PLAN.md` | Standing review findings + ranked improvement backlog |
| `specs/pro-gating-enabled.md` | Source of truth for Kuber Pro gating (limits, gate sheets, products, trial model) |
| `specs/plans/` | Per-feature design plans (cards, credit-card billing, themes, shortcuts, pro) |

## Commands

```bash
flutter run                          # Android device / emulator
flutter run -d chrome                # web
flutter run --dart-define=KUBER_UNLOCK_PRO=true   # QA build with Pro unlocked
flutter build apk                    # release APK
flutter test                         # all tests
flutter analyze                      # must be clean before committing
dart run build_runner build          # regenerate Isar schemas after model changes
flutter gen-l10n                     # regenerate l10n after editing lib/l10n/*.arb
```

Profiling recipe (trace-startup, jank logging) lives in `specs/performance.md` → Verification loop.

## Hard rules (non-negotiable)

1. **Colors**: `Theme.of(context).colorScheme.<role>` or `KuberColors.*`. Never raw hex,
   never `Colors.*` literals. Income → `colorScheme.tertiary`, expense → `colorScheme.error`,
   warning/over-budget → `KuberColors.warning` (no ColorScheme slot).
2. **Radii**: `KuberRadius.*` only (`sm` 4, `md` 8 universal, `lg` 12 bottom sheets).
   **Spacing**: `KuberSpacing.*`.
3. **No drop shadows**. Depth comes from borders (`colorScheme.outlineVariant`).
4. **Typography**: `localeFont()` (Inter / regional Noto) for all UI text, `monoFont()`
   for raw SMS text, sender ids and hashes. No other families; see Performance rules
   for why runtime `GoogleFonts.<family>()` calls are banned.
5. **Both themes**: every screen must be verified in Obsidian (dark) and Alabaster (light).
   Theming is a fixed Vault palette (7 families × light/dark), not M3 dynamic color.
   `dynamic_color` is used only by `harmonizeCategory(context, rawColor)`, which must be
   called before rendering any category color.
6. **Copy**: no em dashes in user-facing text. Currency is ₹ with Indian grouping
   (`1,00,000`) via `ref.watch(formatterProvider).formatCurrency(...)`, never
   `NumberFormat` by hand. User-facing strings go through `context.l10n` (ARBs in `lib/l10n/`);
   Ask Kuber and SMS Import are English-only by design.
7. **Data**: never touch Isar from a widget, always via a repository; writes inside
   `isar.writeTxn()`. After adding a `@collection`, register it in
   `lib/core/database/isar_service.dart` **and** `test/helpers/isar_test_helper.dart`,
   then run `build_runner`.
8. **State**: Riverpod only. `ref.watch()` in `build`, `ref.read()` in callbacks.
   `setState` only for isolated local UI state (focus, text field). Watch narrow with
   `.select()` (performance.md §1).
9. **Performance**: preserve `specs/performance.md` baselines (cold start ~120 ms first
   frame, ≤2 jank frames on tab switch, 0 during scroll). See "Performance rules" below;
   they are measured, not theoretical.
10. **Do not break existing functionality**: check affected providers and repositories
    when adding features. No unrelated refactors.

## Shared components (`lib/shared/widgets/`) — reuse, don't re-layout

| Component | Use it for |
|---|---|
| `KuberAppBar` | Top bar on pushed screens. `showBack` / `showHome`, `infoConfig` (help sheet), `overflowConfig`, `pinShortcut`. Set `showBrand: false` when a `KuberPageHeader` follows. |
| `KuberPageHeader` | Large landing-page title + optional description + optional circular action. **Supplies its own 20 px horizontal padding**: place it as a bare `SliverToBoxAdapter` / child, never inside a horizontal `SliverPadding` (see History `transaction_list_screen.dart`). Body content below uses `KuberSpacing.lg`. |
| `AppButton` (`app_button.dart`) | Primary / secondary / destructive buttons (`AppButtonType`), `isLoading`, `fullWidth`. There is no `KuberButton` class. |
| `KuberBottomSheet` | Shell for all bottom sheets: drag handle, title/subtitle, scrollable `child`, pinned `actions`. Open with `showModalBottomSheet(isScrollControlled: true, useSafeArea: true, ...)`; top radius `KuberRadius.lg`. |
| `InfoTable` + `InfoTableDataRow` / `HighlightRow` / `LabelOnlyRow`, `SheetAmountHero` | Key-value detail blocks inside sheets (transaction detail, calculator results). |
| `SheetButtonSection` + `SheetAction` | Action row at the bottom of a sheet: one `primary`, extra `actions` (overflow when many), `destructive: true` for delete. |
| `KuberInfoBottomSheet` + `KuberInfoConfig` / `KuberInfoItem` (`core/models/info_config.dart`) | The "what is this screen" help sheet, wired via `KuberAppBar(infoConfig:)`. |
| `showKuberSnackBar(context, message, {isError, actionLabel, onAction, duration})` | All toasts. Never `ScaffoldMessenger` directly. |
| Destructive confirm | `showDialog` + `AlertDialog` with `localeFont` styles, cancel `TextButton`, confirm colored `cs.error`. Follow `categories_screen.dart` delete dialogs. |
| `KuberEmptyState`, `KuberSkeleton`, `KuberLoader` | Empty / loading states. Skeleton over spinner for list screens (History pattern). |
| `KuberSegmentedControl`, `KuberDateRangeSelector`, `KuberBarChart`, `CategoryIcon`, `TransactionDetailSheet` | Reuse before building a lookalike. |

Layout: GoRouter `ShellRoute` wraps tab screens in `AppScaffold` (`app_scaffold.dart`);
the FAB and nav rail live there, not in individual screens.

## Feature map

- **Core (free)**: transactions + history, accounts, categories, tags, budgets, recurring,
  loans/ledger, investments, upcoming events, analytics, CSV/PDF export, manual backup,
  home-screen widgets (`widgets_gallery`, `widget_sync_service.dart`), quick actions /
  launcher shortcuts, onboarding + tutorial, app lock (`auth`), 9 locales.
- **Signature** (More tab section): Ask Kuber (`ask_kuber/`), Import from SMS
  (`sms_import/`), Kuber Notes (`notes/`), Kuber Cards (`kuber_cards/`), Quick Add
  (`quick_add/`), Calculators & Tools (`tools/`), Money Stories (`stories/`), Reminders.
- **Kuber Pro**: 8 gated features, limits in `specs/pro-gating-enabled.md`. Single switch
  `KuberProState.hasProAccess` (`pro/paywall/pro_state.dart`). Every gate routes through
  `proGate(context, ref, gateSheet)`. Entitlement comes from Play Billing
  (`in_app_purchase`, `queryPurchases` on cold start + throttled on resume in `app.dart`),
  persisted in the `UserEntitlement` Isar row. No user accounts, no server.

## Project layout

```
lib/
  main.dart            bootstrap: Isar open → seed → migrations → entitlement → runApp
  app.dart             KuberApp: theme cache, cold-start splash overlay, on-open batch
  core/                constants, database (isar_service, migrations, seed), models,
                       router (app_router.dart), services, theme (app_theme.dart), utils
  features/<name>/     data/ (Isar models + repositories), providers/, screens/, widgets/
  shared/widgets/      the component inventory above
  l10n/                ARBs (app_en.arb is the template)
android/app/src/main/kotlin/com/grs/kuber/   MainActivity (SMS + shortcut channels), widgets/
test/                  mirrors lib/; helpers/isar_test_helper.dart opens a temp Isar
specs/                 see table above
```

## Performance rules (measured on a 6k-transaction ledger, 120 Hz device)

Startup order:
- `main.dart:_bootstrap` runs only what decides the first frame (DB open, migrations,
  entitlement row, theme prefs, recurring processor for splash routing). ~50 ms total.
- `ColdStartSplash` is an overlay painted on top of the already-built Home for ~1.6 s.
  **Any UI-isolate work in that window stutters the splash.** So:
- All on-app-open work lives in `app.dart:_runOnOpenBatch`, which runs only when
  `onOpenBatchReadyProvider` flips true (splash finished, and on a first-of-day start the
  recurring loader has handed off). Never call it from a post-frame callback or
  `_bootstrap`. Any widget that wants to do work "on app open" (like the Home SMS card's
  background scan) reads / `listenManual`s `onOpenBatchReadyProvider` first.
- The tab pre-warm (`_warmTabProviders`) is scheduled from the batch, 1.5 s later.

UI-isolate budget: 8.3 ms at 120 Hz. Anything synchronous over ~10 ms on a large
ledger is a visible hitch if it lands during an animation. Known heavy passes and how
they are kept cheap:
- `widget_sync_service.dart:_syncCharts` pre-filters to the last 6 months before its
  bucket passes. Keep new sub-syncs to one pass over pre-filtered data.
- `history_utils.dart:groupTransactionsByDate` uses int day keys; `DateFormatter.groupHeader`
  caches its `DateFormat` + l10n. Never construct `DateFormat`/`lookupAppLocalizations`
  inside a per-row or per-group loop.
- Isar `findAll()` of the whole transactions table costs ~10 ms of deserialisation on the
  UI isolate per call. Load once per operation and pass the list down (§7 of
  `specs/performance.md`); never re-query per item.

Fonts: only Inter (google_fonts, bundled in `assets/google_fonts/`) and JetBrains Mono
(pubspec `fonts:`, use `monoFont()` from `core/utils/locale_font.dart`). A runtime
`GoogleFonts.<family>()` for any other family parses the font on the UI thread on first
use and then relayouts every route (`fontsChange`), which is a 25 ms stall + a 24 ms
frame. Add new families to pubspec `fonts:`, never as runtime loads.

Platform channels (`MainActivity.kt`): handlers run on the Android main thread, which is
where Flutter's vsync arrives. Any I/O (ContentResolver, files, network) goes on a
background executor with the result posted back to the main looper; `readInbox` is the
pattern.

Verification for any perf-touching change: `flutter analyze`, `flutter test`, then a
profile build on a device with a large ledger (`flutter build apk --profile`), cold start
via `am force-stop` + `am start -W`, and a frame-timings / isolate-stall log (see
`specs/performance.md` → Verification loop). Numbers, not vibes.
