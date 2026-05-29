# Kuber — Improvement Plan

Derived from `REVIEW.md`. Sorted by **impact desc, then effort asc**. Capped at 30 items.

- **Impact:** High / Medium / Low (real user-perceptible or measurable gain)
- **Effort:** S (<2h) / M (half day) / L (1-2 days) / XL (multi-day)
- **Risk:** Low (isolated) / Medium (multiple features) / High (data layer or core providers)

Every item is independently shippable; the app stays releasable after each.

| # | Item | Category | Impact | Effort | Risk | Depends on | Notes |
|---|------|----------|--------|--------|------|------------|-------|
| 1 | Stop CSV merge-import from reusing the CSV `id` (use `Isar.autoIncrement` / collision-skip) | Data Integrity | High | S | Medium | — | Prevents silent overwrite of existing transactions on a non-`override` import. `data_service.dart` `_importTransactions`. |
| 2 | Fix multi-select rebuild: `transactionSelectionProvider.select((s) => s.contains(id))` | Performance | High | S | Low | — | `transaction_row.dart:260`. One tap currently rebuilds every visible row. |
| 3 | Unify currency formatting on `AppFormatter`; delete `CurrencyFormatter` | Architecture / Design | High | S | Low | — | Dashboard cards + `amount_display.dart` currently ignore the user's Indian/US number system. |
| 4 | Batch bulk delete into one transaction + single invalidation | Performance | High | M | Medium | — | `transaction_list_screen.dart` delete loop → add `deleteMany` on the repo/notifier; invalidate deps once. |
| 5 | Wrap app startup (`main()`) in error handling + recovery/error screen | Data Integrity | High | M | Medium | — | Corrupt-DB / migration throw currently = uncaught crash before `runApp`. |
| 6 | Bundle Inter into `assets/google_fonts/` (no call-site changes) | Performance / App Size | High | M | Low | — | Removes runtime font fetch; fixes wrong font on first offline launch. Optionally set `GoogleFonts.config.allowRuntimeFetching = false`. |
| 7 | Precompute `transferId → {from,to}` map once; drop per-row full-list scan | Performance | Medium | S | Low | — | `transaction_row.dart:269`. O(transfers × N) per build → O(1) per row. |
| 8 | Harmonize category color in the live transaction row | Design System | Medium | S | Low | — | `transaction_row.dart:308` — apply `harmonizeCategory` (Hard Rule #4); aligns History with Dashboard/Charts. |
| 9 | Reconcile the two avg-daily/projected spend calcs (or label them distinctly) | Architecture | Medium | S | Low | 17 | `spendingStatsProvider` (90d) vs `burnRateProvider` (month) show conflicting dashboard numbers. |
| 10 | Make `override` CSV import atomic (validate fully before `isar.clear()`) | Data Integrity | Medium | M | Medium | 1 | Failure after clear currently loses all data. Stage/validate, then clear+insert. |
| 11 | Compute all account balances in one pass over the in-memory list | Performance | Medium | M | Medium | — | `accountBalanceProvider` N+1 DB queries → single-pass map keyed by accountId. |
| 12 | Expose a `warning` color (theme extension) and replace hardcoded golds | Design System | Medium | M | Low | — | ~15 stable files use 3 drifting literals; `KuberColors.warning` already exists. Excludes off-limits `insight_engine.dart`. |
| 13 | Route the stats/burn-rate providers through the shared `aggregate()` helper | Architecture | Medium | M | Medium | 9 | Removes 4 hand-rolled filter+fold copies; one source of truth for "what counts as spend". |
| 14 | Add `.autoDispose` to date/range-keyed families | Performance | Medium | S | Low | — | `monthlyTransactionsProvider` and analytics range families cache forever; bounds session memory. |
| 15 | Defer ledger-reminder pass (and reconsider recurring) to post-first-frame | Performance | Medium | M | Medium | 5 | Cold start scales with data while native splash shows. Budget alerts already deferred — mirror that. |
| 16 | Remove unused `another_flushbar` dependency | App Size | Medium | S | Low | — | No imports anywhere; only a comment references it. |
| 17 | Delete dead files: `legacy_kuber_nav_bar.dart`, `transaction_list_item.dart`, `amount_display.dart` | App Size / Code Health | Medium | S | Low | 3 | All unreachable. `amount_display.dart` deletion folds into the formatter unification (#3). |
| 18 | Correct `CLAUDE.md` / `specs/AGENTS.md` to describe the Vault system | Code Health | Medium | S | Low | — | Currently say M3/`dynamic_color`/`colorScheme.tertiary`/radius 28 — primes future changes with wrong rules. |
| 19 | Add edge-case tests for `CurrencyInputFormatter` | Code Health | Medium | M | Low | — | Repeatedly fixed (sign, decimals, cursor); lock behavior for `-`, `0.`, multi-dot, paste before next change. |
| 20 | Audit & resolve `BoxShadow` usages against the no-shadow rule | Design System | Low | S | Low | — | 7 stable files; confirm each is intentional or convert to border. Graph component excluded. |
| 21 | Replace local `_kBlue/_kGreen/_kRed` literals in tools hub with `KuberColors` | Design System | Low | S | Low | — | `tools_hub_screen.dart:65-71` duplicate existing tokens. |
| 22 | Extract a single `rebuildAllSuggestions(isar)` helper | Architecture | Low | S | Low | — | De-dupes the 4 copied upsert loops (migrations, importJson, CSV import, mock data). |
| 23 | Type the `formatter` param (`AppFormatter`, not `dynamic`) | Architecture | Low | S | Low | 3 | `transaction_row.dart` — restores type safety on the hot list. |
| 24 | Remove tracked stale artifacts `analysis_report.txt`, `analysis_report_2.txt` | Code Health | Low | S | Low | — | Old dumps committed at repo root. |
| 25 | Remove commented-out code blocks | Code Health | Low | S | Low | — | e.g. `app_scaffold.dart:726-747`, `transaction_list_screen.dart:107-109`. |
| 26 | Triage stale TODOs (wire up or remove) | Code Health | Low | S | Low | — | `accounts_screen.dart:192`, `net_worth_hero_card.dart:32`, `more_screen_modern.dart:44`. |
| 27 | De-duplicate the page-jump/animate block in `app_scaffold.dart` | Animation / Code Health | Low | S | Low | — | Same sequencing in `didUpdateWidget` and `_onTabTapped` → one private method. |
| 28 | Gate `debugPrint` (esp. swallowed import-row failures) behind `kDebugMode` / surface errors | Code Health | Low | S | Low | — | `data_service.dart`, `stats_provider.dart`. |
| 29 | Migrate the 6 legacy `StateNotifier`s to `Notifier` | Architecture | Low | M | Low | — | Consistency only; do opportunistically when touching each file. |
| 30 | Extract self-contained bottom sheets out of the largest screens | Code Health | Low | L | Medium | — | Start with `add_transaction_screen.dart` (1082, most-churned) and `categories_screen.dart` (1678). |

---

## Recommended execution order

Each batch is independently shippable and leaves the app releasable.

### Batch A — Data-safety first (ship before anything touches import/startup)
**#1, #5, #10** — close the two data-loss vectors (merge-import id collision; non-atomic override import) and make startup crash-resilient. Highest stakes, mostly isolated to `data_service.dart` and `main.dart`. Do #1 before #10.

### Batch B — Quick high-impact UX/perf wins
**#2, #3, #7, #8** — selection-rebuild `.select`, currency-formatter unification, transfer-pair map, category-color harmonization. All small, low-risk, and directly visible on the two most-used screens (History, Dashboard). #17's `amount_display.dart` deletion rides along with #3.

### Batch C — Startup & list performance
**#4, #6, #11, #14, #15** — bulk-delete batching, font bundling, single-pass account balances, family autoDispose, deferred startup processing. Touch core providers/startup, so ship after Batch A's safety net and verify on a large dataset.

### Batch D — Consistency & dedup
**#9, #13, #12, #18, #21, #22, #23** — reconcile spend calcs then route them through the shared aggregate helper (#9 → #13), warning-color token, fix the agent docs, dedup tokens/suggestion-loop/formatter type. #18 first in this batch so subsequent work follows correct rules.

### Batch E — Cleanup & hygiene (low risk, anytime)
**#16, #17, #19, #20, #24, #25, #26, #27, #28** — drop unused dep, delete dead files, add formatter tests, shadow audit, remove cruft/commented code/TODOs, de-dup the animate block, gate logging.

### Batch F — Opportunistic / background
**#29, #30** — notifier migration and large-file decomposition. No user-facing payoff; do incrementally while already editing those files to avoid churn-for-churn's-sake.
