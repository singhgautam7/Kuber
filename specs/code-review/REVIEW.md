# Kuber — Codebase Review

Review-only pass. No code changed. Findings only; fixes live in `PLAN.md`.

Scope notes:
- Off-limits areas (stories/insights, automatic backups, widget editor, notification system, shared date range selector, graph component) were excluded. Where a problem is cross-cutting, only the stable-side occurrence is reported.
- The design language reviewed against is **Vault** (`specs/design-system.md`): `KuberColors.*`, `KuberRadius.*`, borders not shadows, Inter-only. Note `CLAUDE.md`/`specs/AGENTS.md` still describe an older M3 / `dynamic_color` / `colorScheme.<role>` / `KuberSpacing` system — see CH-1.
- `flutter analyze` is clean (0 issues) under `flutter_lints`.

---

## Architecture and patterns

**Two parallel currency formatters, one of them locale-blind**
- Location: `lib/core/utils/currency_formatter.dart` (`CurrencyFormatter.format`) vs `lib/core/utils/formatters.dart` (`AppFormatter` via `formatterProvider`)
- Observation: `AppFormatter` (used in ~58 files) is locale-aware and honours the user's Indian/US `NumberSystem`. `CurrencyFormatter.format` hardcodes `NumberFormat('#,##0.00')` and is used in 6 places, including dashboard cards (`monthly_summary_card.dart`, `burn_rate_card.dart`, `home_recurring_card.dart`, `budget_snapshot_card.dart`, `analytics/widgets/budget_vs_actual.dart`) and the shared `amount_display.dart`.
- Why it matters: a user on the Indian number system sees `₹12,34,567` everywhere except those dashboard cards, which render `₹1,234,567.00` (Western grouping, forced 2 decimals). Same screen, two grouping conventions — a visible inconsistency, and it ignores the user's explicit setting.

**Aggregation logic re-implemented despite a shared helper existing**
- Location: `lib/features/transactions/helpers/transaction_filters.dart` (`aggregate(TxnPeriodFilter)`) vs `lib/features/transactions/providers/stats_provider.dart` (`analyticsCategoryStatsProvider`, `analyticsGroupStatsProvider`), `transaction_provider.dart` (`spendingStatsProvider`), `stats_provider.dart` (`burnRateProvider`)
- Observation: a well-designed single-pass `aggregate()` helper exists and is used by the dashboard monthly hero and Categories hero. But category-stat, group-stat, spending-stat and burn-rate providers each hand-roll their own `where(...).fold(...)` loops with subtly different inclusion rules (e.g. `int.tryParse(categoryId)` vs string keys, `linkedRuleType` excluded in one place but not another).
- Why it matters: the same "what counts as spend" rule is encoded 4+ times. A future change to, say, how transfers or balance adjustments are excluded must be made in every copy or totals silently diverge across screens.

**Two divergent "average daily / projected" spend calculations on the same dashboard**
- Location: `spendingStatsProvider` (`lib/features/transactions/providers/transaction_provider.dart`) feeds `spending_stats_card.dart`; `burnRateProvider` (`lib/features/transactions/providers/stats_provider.dart`) feeds `burn_rate_card.dart`
- Observation: `spendingStatsProvider` computes avg daily from a **90-day rolling window** then projects `avgDaily * daysInMonth`. `burnRateProvider` computes avg daily from **current-month-to-date** (`totalSpend / daysElapsed`) then projects the same way. They also differ on `linkedRuleType` handling.
- Why it matters: two cards on the home screen can show two different "average daily spend" and two different month projections from the same data — users notice contradictory numbers and lose trust in the figures.

**N+1 query pattern for account balances**
- Location: `lib/features/accounts/providers/account_provider.dart` → `accountBalanceProvider` (family)
- Observation: the provider `ref.watch(transactionListProvider)` (the full in-memory list) but then issues a **separate Isar query** per account (`isar.transactions.filter().accountIdEqualTo(...).findAll()`) and folds it. With N accounts you get N DB round-trips on every transaction change, even though every transaction is already in memory.
- Why it matters: the accounts screen / net-worth hero / home accounts card recompute N queries each time any transaction is added or edited. One pass over the already-loaded list would produce all balances at once.

**`formatter` threaded through the transaction list as `dynamic`**
- Location: `lib/features/transactions/widgets/transaction_row.dart` (`TransactionDayCard.formatter`, `TransactionRow.formatter` both `final dynamic formatter;`)
- Observation: the `AppFormatter` is passed as `dynamic`, so `formatter.formatCurrency(...)` is a dynamic (runtime) dispatch with no compile-time checking, on the hottest list in the app.
- Why it matters: loses type safety on a widget rendered once per visible transaction, and every call goes through dynamic dispatch.

**"Rebuild all suggestions" loop copy-pasted in four places**
- Location: `lib/core/database/migrations.dart` (`_backfillSuggestions`), `lib/core/services/data_service.dart` (`importJson`, `_importTransactions`, `generateMockData`)
- Observation: the same "iterate every transaction, `if (!isTransfer) upsertSuggestion(tx)`" loop appears four times with slightly different batching.
- Why it matters: four copies of the rebuild contract; easy for one to drift (e.g. one batches and yields, others block the event loop on large datasets).

**Mixed Riverpod provider idioms for similar concerns**
- Location: project-wide — 6 `StateNotifier` (`data_provider.dart`, `tutorial_provider.dart`, `tools_hub_screen.dart`, `auth_provider.dart`, `history_filter_provider.dart`, `analytics_provider.dart`) alongside 24 modern `Notifier`/`AsyncNotifier`, plus `StateProvider`, `FutureProvider`, one `ChangeNotifier`
- Observation: legacy `StateNotifier` and modern `Notifier` are both used for comparable "mutable filter/UI state" concerns.
- Why it matters: contributors must context-switch between two notifier APIs for the same kind of state; not a bug, but a consistency tax (low priority).

---

## Performance

**Every transaction row rebuilds on any selection toggle**
- Location: `lib/features/transactions/widgets/transaction_row.dart:260` — `ref.watch(transactionSelectionProvider).contains(transaction.id)`
- Observation: each `TransactionRow` watches the whole `Set<int>` selection provider and calls `.contains`. Toggling one row mutates the Set, so **every** visible row rebuilds.
- Why it matters: on a long history list in multi-select, each tap rebuilds the entire on-screen list → visible jank during selection. `ref.watch(provider.select((s) => s.contains(id)))` would limit rebuilds to the one row whose membership changed.

**Transfer-pair lookup scans the full transaction list per row, per build**
- Location: `lib/features/transactions/widgets/transaction_row.dart:269` — `transactionList.firstWhereOrNull(...)`
- Observation: for every transfer row, `build()` linearly scans the entire transaction list (passed down whole) to find the paired leg's account. This repeats on every rebuild (e.g. selection toggles, see above).
- Why it matters: O(transfers × total-transactions) work on the history list each frame it rebuilds. For users with years of data this compounds with the selection-rebuild issue into noticeable scroll/selection lag. A precomputed `transferId → {from,to}` map built once per list would make each row O(1).

**Bulk delete fans out into N full reloads**
- Location: `lib/features/transactions/screens/transaction_list_screen.dart:599-605` (loop) → `transaction_provider.dart` `delete()`
- Observation: `for (final id in selectedIds) { await notifier.delete(id); }`. Each `delete()` calls `ref.invalidateSelf()` + `_invalidateDependencies()` (invalidates `categoryListProvider` and `budgetListProvider`) + a budget-alert pass. Deleting 50 selected rows = 50 sequential DB deletes + 50 full transaction-list reloads + 50 category/budget invalidations + 50 alert passes.
- Why it matters: bulk delete of a large selection is quadratic-ish and visibly slow / janky. A single batched delete with one invalidation at the end would be dramatically faster.

**Fonts fetched at runtime instead of bundled (offline-first violation + per-call cost)**
- Location: `pubspec.yaml` (no `fonts:` section, no `assets/google_fonts/`), `lib/core/theme/app_text_styles.dart`, and **865** direct `GoogleFonts.inter(...)` call sites across 116 files
- Observation: Inter is not bundled, so `google_fonts` attempts an HTTP fetch on first use and falls back to the platform font until the download succeeds and is cached. `AppTextStyles` was explicitly created to centralise this (its own doc comment cites jank), yet 865 call sites still call `GoogleFonts.inter()` directly.
- Why it matters: for a "local-first" app, the **first launch with no network renders in the wrong font** (Roboto fallback), then snaps to Inter once online — a poor first impression and a correctness gap for an offline product. Bundling Inter into `assets/google_fonts/` removes the runtime fetch entirely with zero call-site changes.

**Riverpod families are never auto-disposed**
- Location: 21 `.family` providers vs 1 `autoDispose` in the codebase; e.g. `monthlyTransactionsProvider` (`transaction_provider.dart`), date/range-keyed analytics families
- Observation: date-keyed families cache one result per key for the whole app lifetime. Browsing many months/ranges accumulates filtered copies of the transaction list in memory.
- Why it matters: unbounded-key families (anything keyed by a date/range/query) grow memory the longer the session runs. `autoDispose` on the date-keyed ones bounds this without behaviour change.

**Heavy work on the main isolate before the first frame**
- Location: `lib/main.dart` `main()` — `IsarService.open()` → `SeedService` → `MigrationService.runAll` → `NotificationService.init` → `RecurringProcessor.processAll()` → `LedgerReminderProcessor.checkAll()`, all awaited before `runApp`
- Observation: recurring processing and ledger-reminder scanning run on every cold start before any UI appears. (Budget alerts are already correctly deferred to a post-frame callback in `app.dart`.)
- Why it matters: cold-start time scales with data volume while the user stares at the native splash. `processAll()`'s result is only needed to decide whether to show the recurring-loader screen; the ledger reminder pass could run post-first-frame.

---

## Animation quality

**Duplicated page-jump/animate block**
- Location: `lib/shared/widgets/app_scaffold.dart` — `didUpdateWidget` (lines ~84-115) and `_onTabTapped` (lines ~131-157)
- Observation: the "if distance > 1, jumpToPage to neighbour then animateToPage in a post-frame callback, toggling `_isAnimatingProgrammatically`" logic is duplicated almost verbatim in two methods.
- Why it matters: tab-switch animation is one of the most-touched, most-fragile areas (see Git Signals); two copies of the same finicky sequencing mean fixes/regressions must be mirrored. Otherwise animation hygiene is good — controllers are disposed, curves are applied, `RepaintBoundary` wraps the sweep-ring painter.

---

## App size

**Unused dependency: `another_flushbar`**
- Location: `pubspec.yaml` → `another_flushbar: ^1.12.30`; no `package:another_flushbar` import anywhere (only a comment in `timed_snackbar.dart` references the concept)
- Observation: the custom `TimedSnackBar` replaced Flushbar; the package is dead weight.
- Why it matters: ships an unused package in a 12 MB-budget app. Clean removal.

**Dead files / unused widgets**
- Location: `lib/shared/widgets/legacy_kuber_nav_bar.dart` (imported nowhere — the live `KuberNavRail` is in `kuber_nav_bar.dart`); `lib/features/transactions/widgets/transaction_list_item.dart` (`TransactionListItem` imported nowhere); `lib/shared/widgets/amount_display.dart` (`AmountDisplay` referenced nowhere)
- Observation: three unreachable UI files. Notably `transaction_list_item.dart` is the one that *does* harmonize category colors, while the live row widget does not (see Design System).
- Why it matters: dead code inflates the tree, confuses contributors (which row widget is real?), and `amount_display.dart` carries the locale-blind formatter bug into a widget that looks reusable.

**`cupertino_icons` not referenced in `lib`**
- Location: `pubspec.yaml`; 0 usages in `lib`
- Observation: standard Flutter template dep, but unused here.
- Why it matters: tiny, low priority — flagged only for completeness.

---

## Design system consistency

**Category colors not harmonized in the live transaction list (violates Hard Rule #4)**
- Location: `lib/features/transactions/widgets/transaction_row.dart:308` — `iconColor = Color(category!.colorValue)` passed raw to `CategoryIcon.square`
- Observation: `CategoryIcon` renders `rawColor` directly (no internal harmonization). ~17 surfaces call `harmonizeCategory(context, rawColor)` first (charts, top-categories, pickers, recurring), but the history row — the most-viewed list — passes the raw stored color.
- Why it matters: the same category renders a (subtly) different colour in History vs Dashboard/Charts, and it directly breaks the project's stated hard rule that category colours must be harmonized before rendering.

**Hardcoded "warning/gold" colours, with drift, despite a token existing**
- Location: `KuberColors.warning` (`0xFFF59E0B`) exists in `app_theme.dart`, but raw warning colours are hardcoded across ~15 stable files: `0xFFF59E0B` (`add_transaction_screen.dart:368`, `account_card.dart:380` — comment even says "no slot on ColorScheme", `recurring_widgets.dart`, `home_accounts_card.dart:284`, `categories_screen`/`category_widgets.dart:601`), `0xFFFFB300` (`more_screen.dart:131`, `more_search_screen.dart:63`, `more_screen_modern.dart:1005`, `home_header.dart:75`), `0xFFD4A017` (`transaction_row.dart:167`)
- Observation: because Material's `ColorScheme` has no "warning" slot, every feature reaches for a literal — and they've drifted to at least three different golds.
- Why it matters: inconsistent warning colour across the app, and no single source of truth. Exposing `warning` via a theme extension (or standardising on `KuberColors.warning`) fixes both. (Hardcoded colours inside off-limits `insight_engine.dart` were excluded.)

**Design tokens re-declared locally**
- Location: `lib/features/tools/tools_hub_screen.dart:65-71` — `_kBlue = Color(0xFF3B82F6)`, `_kGreen = Color(0xFF22C55E)`, `_kRed = Color(0xFFEF4444)`, etc.
- Observation: these literals duplicate `KuberColors.primary/income/expense` exactly.
- Why it matters: if the palette ever shifts, the tools hub silently keeps the old values.

**Drop shadows present despite "borders only" rule**
- Location: `BoxShadow` in stable files: `add_edit_category_screen.dart:420`, `account_form.dart:236`, `add_alert_bottom_sheet.dart:358`, `analytics_toggle.dart:40`, `kuber_page_header.dart:92`, `timed_snackbar.dart:255`, `kuber_calculator.dart:548` (the `kuber_bar_chart.dart` occurrence is in the off-limits graph component)
- Observation: Vault specifies border-based separation and "no `BoxShadow`". Several components use shadows.
- Why it matters: visual inconsistency with the design language; some may be intentional (e.g. a dragged/elevated affordance) and should be confirmed rather than blanket-removed — needs a quick audit.

---

## Data integrity and safety

**CSV merge-import can silently overwrite existing transactions**
- Location: `lib/core/services/data_service.dart` `_importTransactions` — `..id = int.tryParse(row['id'] ?? '') ?? Isar.autoIncrement`
- Observation: import preserves the `id` column from the CSV. With `override: false` (merge), `isar.transactions.put(tx)` on a CSV id that collides with an existing transaction's autoincrement id **overwrites** that existing record. Exports include `id`, so importing a file produced on another device/db (different id space) can clobber unrelated transactions.
- Why it matters: silent data loss on a merge import — directly contradicts the "data integrity is non-negotiable" constraint. Merge imports should let Isar assign fresh ids (or detect/skip collisions).

**`override` import is non-atomic — failure after clear loses everything**
- Location: `lib/core/services/data_service.dart` `importData` — `if (override) { await isar.writeTxn(() => isar.clear()); } return await _importTransactions(rows);`
- Observation: the wipe is its own transaction, separate from the (multi-transaction) insert phase. If `_importTransactions` throws partway (or the app is killed), the user's data is already gone and only partially restored.
- Why it matters: a failed "replace all data" import is unrecoverable. Parsing/validating fully before clearing (or staging then swapping) preserves the old data on failure.

**No error handling around app startup**
- Location: `lib/main.dart` `main()`
- Observation: `IsarService.open()`, migrations and the on-open processors are awaited with no try/catch. An open failure (corrupt DB, locked file, migration throw) propagates uncaught before `runApp`.
- Why it matters: any startup exception yields a crash / blank screen on launch with no recovery path or message for a live user — the worst failure mode for a shipped app.

---

## Code health

**Several very large, multi-concern files**
- Location: `categories_screen.dart` (1678), `more/screens/ask_kuber_screen.dart` (1566), `tools/bill_splitter/add_edit_bill_screen.dart` (1335), `more_screen_modern.dart` (1114), `transactions/screens/add_transaction_screen.dart` (1082), `settings/screens/settings_screen.dart` (1041)
- Observation: these mix screen scaffolding, multiple bottom sheets, form logic, and inline widget definitions in one file.
- Why it matters: they're disproportionately represented in the churn list (below); large files concentrate merge conflicts and make the fragile bits (e.g. add-transaction) hard to reason about. Low user-facing value, so low priority — but worth extracting the self-contained sheets.

**Commented-out code blocks**
- Location: ~126 comment lines that look like code, e.g. `app_scaffold.dart:726-747` (disabled speed-dial options), `transaction_list_screen.dart:107-109` (disabled app bar), `more_screen_modern.dart:22-23`
- Observation: dead commented blocks left inline.
- Why it matters: noise that suggests indecision and rots over time; version control already preserves history.

**Stale TODOs marking unfinished features**
- Location: `accounts_screen.dart:19,192` ("route to AddTransactionScreen with this account"), `net_worth_hero_card.dart:32` ("compute from transactions grouped by month"), `more_screen_modern.dart:44` ("re-use the existing launchTutorialFromMore helper")
- Observation: TODOs older than the recent work cycles, some indicating half-wired UI affordances.
- Why it matters: either a missing feature users can tap into a dead end, or cruft to remove. Worth triaging.

**Project docs contradict the actual design system**
- Location: `CLAUDE.md` and `specs/AGENTS.md` ("M3 color roles", `colorScheme.<role>`, `KuberSpacing.*`, `dynamic_color`, "income → `colorScheme.tertiary`", bottom-sheet radius 28) vs `specs/design-system.md` + actual code (Vault: `KuberColors`, `KuberRadius`, fixed palette, sheet radius `KuberRadius.lg`=12)
- Observation: the agent-facing instructions describe a superseded system. `KuberSpacing` does exist, but the colour/theming guidance is wrong; `dynamic_color` is now used only for one `harmonizeWith` call.
- Why it matters: every future automated/contributor change is primed with incorrect rules (e.g. "use `colorScheme.tertiary` for income", "radius 28") — a direct cause of the inconsistencies above. Cheap to fix, high leverage.

**`debugPrint` on production paths**
- Location: 10 sites, e.g. `data_service.dart` (`_saveFile`, row-import failures), `stats_provider.dart` error handlers
- Observation: `debugPrint` runs in release builds (throttled). Minor.
- Why it matters: low — flagged for completeness; swallowed import-row failures via `debugPrint` only also hide real import problems from users.

---

## Git signals

**Churn hotspots (instability)**
- Location (last ~200 commits, edits): `app_scaffold.dart` (22), `add_transaction_screen.dart` (22), `more_screen.dart` (22), `transaction_list_screen.dart` (20), `analytics_screen.dart` (20), `app_router.dart` (20), `dashboard_screen.dart` (19)
- Observation: `app_scaffold.dart` concentrates tab/page-sync + Android-13 back-handling + speed dial; it carries the duplicated animate block and commented code noted above. `add_transaction_screen.dart` (1082 lines) is both huge and the most-edited screen.
- Why it matters: repeated edits to the same complex files signal designs that fight the contributor. The back-navigation/page-sync logic (split across `app.dart` `didPopRoute`/`_handleNavigationNotification` and `app_scaffold.dart`) is the clearest candidate for a focused consolidation pass.

**Repeated currency-input fixes**
- Location: `CurrencyInputFormatter` (`formatters.dart`); recent commits `606d9ed`, `9aaf43b` ("preserve negative sign", "regional currency input formatting")
- Observation: the input formatter has needed multiple cursor/sign/decimal fixes.
- Why it matters: a sign that `CurrencyInputFormatter`'s cursor-offset/decimal handling is fragile; worth targeted tests around its edge cases (`-`, `0.`, multiple dots, paste) before the next change.
