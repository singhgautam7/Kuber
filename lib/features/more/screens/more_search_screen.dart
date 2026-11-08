import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/schedule/schedule_engine.dart' show dayOf;
import '../../../core/schedule/schedule_text.dart' show fmtDayShort;
import '../../../core/utils/l10n_ext.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_progress.dart';
import '../../../shared/widgets/kuber_search_pill.dart';
import '../../../shared/widgets/kuber_search_result.dart';
import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../accounts/widgets/account_detail_sheet.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../dev/providers/dev_mode_provider.dart';
import '../../history/providers/history_filter_provider.dart';
import '../../investments/data/investment.dart';
import '../../investments/providers/investment_provider.dart';
import '../../investments/widgets/holding_sheet.dart';
import '../../kuber_cards/providers/kuber_cards_provider.dart';
import '../../ledger/data/ledger.dart';
import '../../ledger/providers/ledger_provider.dart';
import '../../ledger/utils/ledger_calculations.dart' as calc;
import '../../ledger/widgets/ledger_detail_sheet.dart';
import '../../loans/data/loan.dart';
import '../../loans/domain/loan_engine.dart';
import '../../loans/providers/loan_provider.dart';
import '../../loans/widgets/loan_sheet.dart';
import '../../notes/providers/notes_provider.dart';
import '../../onboarding/widgets/onboarding_entrance.dart';
import '../../recurring/data/recurring_rule.dart';
import '../../recurring/providers/recurring_provider.dart';
import '../../recurring/widgets/rule_sheet.dart';
import '../../reminders/data/reminder.dart';
import '../../reminders/providers/reminders_provider.dart';
import '../../reminders/widgets/reminder_view_sheet.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/settings_index.dart';
import '../../tags/data/tag.dart';
import '../../tags/providers/tag_providers.dart';
import '../../tags/widgets/tag_bottom_sheets.dart';
import '../../tools/tool_catalog.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../more_content.dart';
import '../more_search_index.dart';
import 'categories_screen.dart' show showCategoryDetails;

/// Rows per group before "See all".
const int _groupRows = 3;

/// More search (board v4.4): settings, data and tools by name. Settings and
/// tools show at once; data is read once when the page opens, then every
/// keystroke filters lists in memory.
class MoreSearchScreen extends ConsumerStatefulWidget {
  final BuildContext hostContext;
  const MoreSearchScreen({super.key, required this.hostContext});

  @override
  ConsumerState<MoreSearchScreen> createState() => _MoreSearchScreenState();
}

class _MoreSearchScreenState extends ConsumerState<MoreSearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  Timer? _waiting;
  String _query = '';
  MoreSearchKind? _filter;
  List<String> _recents = const [];

  /// Tools and features: known at once.
  List<MoreSearchItem>? _static;

  /// Everything from the database, once it has loaded.
  List<MoreSearchItem>? _data;

  /// Data still isn't here 150 ms after it was needed.
  bool _slow = false;

  /// Groups rise in on the first result set only.
  bool _risen = false;

  @override
  void initState() {
    super.initState();
    MoreSearchRecents.load().then((r) {
      if (mounted) setState(() => _recents = r);
    });
    // Once the page has landed: the settings index, then the data, so neither
    // lands on the opening animation.
    Future<void>.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;
      SettingsSearch.of(context.l10n);
      _loadData();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _waiting?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _static ??= _buildStatic();
  }

  List<MoreSearchItem> _buildStatic() {
    final l = context.l10n;
    final isDevMode = ref.read(devModeProvider).valueOrNull ?? false;
    return [
      for (final g in ToolCatalog.groups)
        for (final t in g.tools)
          MoreSearchItem(
            kind: MoreSearchKind.calculators,
            title: t.name,
            subtitle: l.menuCalculators,
            icon: t.icon,
            target: '/more/tools/${t.key}',
          ),
      // Unlocked from About; its row lives in Settings.
      if (isDevMode)
        MoreSearchItem(
          kind: MoreSearchKind.features,
          title: l.menuDevTools,
          subtitle: l.settingsTitle,
          icon: Icons.bug_report_outlined,
          target: '/more/dev-tools',
        ),
      for (final s in buildMoreSections(widget.hostContext, ref))
        for (final e in s.entries)
          MoreSearchItem(
            kind: MoreSearchKind.features,
            title: splitTrailingTag(e.label).$1,
            subtitle: '${l.navMore} › ${s.title}',
            icon: e.icon,
            target: e,
          ),
    ];
  }

  Future<void> _loadData() async {
    final l = context.l10n;
    final fmt = ref.read(formatterProvider);
    final locale = l.localeName;
    final symbol = ref.read(currencyProvider).symbol;
    final accounts = (await ref.read(allAccountsProvider.future)).where((a) => !a.isDisabled).toList();
    final results = await Future.wait<Object?>([
      ref.read(accountBalancesProvider.future),
      ref.read(categoryListProvider.future),
      ref.read(categoryGroupListProvider.future),
      ref.read(tagListProvider.future),
      ref.read(transactionTagsMapProvider.future),
      ref.read(recurringListProvider.future),
      ref.read(loanListProvider.future),
      ref.read(investmentListProvider.future),
      ref.read(ledgerListProvider.future),
      ref.read(remindersStreamProvider.future),
      ref.read(storedCardsProvider.future),
      ref.read(notesStreamProvider.future),
      ref.read(transactionListProvider.future),
      ref.read(loanDeletedDaysProvider.future),
    ]);
    if (!mounted) return;
    final tagUse = <int, int>{};
    for (final ids in (results[4]! as Map<int, Set<int>>).values) {
      for (final id in ids) {
        tagUse[id] = (tagUse[id] ?? 0) + 1;
      }
    }
    final txns = results[12]! as List;
    final loans = results[6]! as List<Loan>;
    final deleted = results[13]! as Map<String, Set<int>>;
    final loanInfo = <String, ({double? outstanding, String? next})>{};
    if (loans.isNotEmpty) {
      for (final loan in loans) {
        final linked = [
          for (final t in txns)
            if (t.linkedRuleType == 'loan' && t.linkedRuleId == loan.uid) t,
        ];
        final st = loanStatus(loan, linked.cast(), deletedDays: deleted[loan.uid] ?? const {});
        loanInfo[loan.uid] = (
          outstanding: st.closed ? null : st.outstanding,
          next: st.nextDay == null ? null : fmtDayShort(dayOf(st.nextDay!)),
        );
      }
    }
    final ledgers = results[8]! as List<Ledger>;
    final items = MoreSearchItems.build(
      MoreSearchData(
        accounts: accounts,
        balances: results[0]! as Map<int, double>,
        categories: results[1]! as List<Category>,
        groups: (results[2]! as List).cast(),
        tags: (results[3]! as List).cast(),
        tagCounts: tagUse,
        rules: (results[5]! as List).cast(),
        loans: loans,
        loanInfo: loanInfo,
        investments: (results[7]! as List).cast(),
        ledgers: ledgers,
        remaining: {
          for (final p in ledgers)
            p.uid: calc.computeRemaining(p, txns.cast()).clamp(0, double.infinity).toDouble(),
        },
        reminders: (results[9]! as List).cast(),
        cards: (results[10]! as List).cast(),
        notes: (results[11]! as List).cast(),
      ),
      l: l,
      fmt: fmt,
      mask: '$symbol ••••',
      locale: locale,
      typeOf: (i) => investmentTypeLabel(context, i.investmentType),
    );
    if (!mounted) return;
    _waiting?.cancel();
    setState(() {
      _data = items;
      _slow = false;
    });
  }

  void _onChanged(String v) {
    _debounce?.cancel();
    if (v.trim().isEmpty) {
      setState(() {
        _query = '';
        _filter = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() => _query = v);
      if (_data == null && _waiting == null) {
        _waiting = Timer(KuberMotion.fast, () {
          if (mounted && _data == null) setState(() => _slow = true);
        });
      }
    });
  }

  void _search(String q) {
    _controller.value = TextEditingValue(
      text: q,
      selection: TextSelection.collapsed(offset: q.length),
    );
    _debounce?.cancel();
    setState(() => _query = q);
  }

  void _setRecents(List<String> list) {
    setState(() => _recents = list);
    MoreSearchRecents.save(list);
  }

  String _kindName(MoreSearchKind k, AppLocalizations l) => switch (k) {
        MoreSearchKind.settings => l.settingsTitle,
        MoreSearchKind.accounts => l.menuAccounts,
        MoreSearchKind.categories => l.menuCategories,
        MoreSearchKind.tags => l.menuTags,
        MoreSearchKind.recurring => l.menuRecurring,
        MoreSearchKind.loans => l.menuLoans,
        MoreSearchKind.investments => l.menuInvestments,
        MoreSearchKind.people => l.menuLedger,
        MoreSearchKind.reminders => l.appDrawerReminders,
        MoreSearchKind.cards => l.appDrawerCards,
        MoreSearchKind.notes => l.appDrawerNotes,
        MoreSearchKind.calculators => l.menuCalculators,
        MoreSearchKind.features => l.searchFeatures,
      };

  /// All groups for the query, in the fixed order.
  Map<MoreSearchKind, List<MoreSearchItem>> _results(AppLocalizations l) {
    final q = _query.trim();
    if (q.isEmpty) return const {};
    final search = SettingsSearch.of(l);
    final found = MoreSearchItems.match([..._static ?? const [], ..._data ?? const []], q);
    final settings = [
      for (final e in search.search(q))
        MoreSearchItem(
          kind: MoreSearchKind.settings,
          title: e.title(l),
          subtitle: settingsPath(e.area, l, l.settingsTitle),
          icon: e.icon,
          target: e,
          matches: search.keywordHit(e, q) == null ? null : l.searchMatches(search.keywordHit(e, q)!),
        ),
    ];
    return {
      for (final k in MoreSearchKind.values)
        if (k == MoreSearchKind.settings && settings.isNotEmpty)
          k: settings
        else if (found[k] case final list?)
          k: list,
    };
  }

  Future<void> _open(MoreSearchItem item) async {
    _setRecents(MoreSearchRecents.added(_recents, _query));
    final host = widget.hostContext;
    final hostRef = ref;
    Navigator.of(context).pop();
    switch (item.target) {
      case SettingsEntry e:
        host.push(e.area == SettingsArea.pro ? e.area.route : '${e.area.route}?row=${e.id}');
      case MoreEntry e:
        e.onTap();
      case String route:
        host.push(route);
      case Account a:
        _sheet(host, AccountDetailSheet(account: a));
      case Category c:
        final groups = hostRef.read(categoryGroupListProvider).valueOrNull;
        final group = groups?.where((g) => g.id == c.groupId).firstOrNull;
        showCategoryDetails(host, hostRef, c, group?.name);
      case Tag t:
        _sheet(host, ViewTagBottomSheet(tag: t));
      case RecurringRule r:
        showRuleSheet(host, hostRef, r);
      case Loan loan:
        showLoanSheet(host, hostRef, loan);
      case Investment i:
        showHoldingSheet(host, hostRef, i);
      case Ledger p:
        _sheet(host, LedgerDetailSheet(ledger: p));
      case Reminder r:
        showReminderViewSheet(host, r);
      case int id when item.kind == MoreSearchKind.notes:
        // The Notes lock sits on the Notes page: its result goes through there.
        final locked = hostRef.read(notesBiometricRequiredProvider) &&
            !hostRef.read(notesUnlockedThisSessionProvider);
        host.push(locked ? '/more/notes' : '/notes/editor?id=$id');
      case int _:
        // Always asks for the Cards PIN or fingerprint, even with the vault
        // unlocked earlier in this session.
        hostRef.read(cardSessionProvider.notifier).lock();
        host.push('/cards');
    }
  }

  void _sheet(BuildContext host, Widget sheet) {
    showModalBottomSheet<void>(
      context: host,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => sheet,
    );
  }

  void _toHistory() {
    final q = _query.trim();
    ref.read(historyFilterProvider.notifier).setSearchQuery(q);
    final host = widget.hostContext;
    Navigator.of(context).pop();
    host.go('/history');
  }

  Widget _leading(MoreSearchItem i, ColorScheme cs) {
    if (i.kind == MoreSearchKind.categories) {
      return CategoryIcon.square(icon: i.icon, rawColor: i.color ?? cs.primary, size: 40);
    }
    if (i.kind == MoreSearchKind.people) {
      final letters = i.title.trim().split(RegExp(r'\s+')).take(2).map((w) => w.characters.first).join();
      return Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: cs.tertiaryContainer, shape: BoxShape.circle),
        child: Text(
          letters.toUpperCase(),
          style: Theme.of(context).textTheme.titleSmall!.copyWith(color: cs.onTertiaryContainer),
        ),
      );
    }
    final (bg, fg) = switch (i.kind) {
      MoreSearchKind.settings ||
      MoreSearchKind.recurring ||
      MoreSearchKind.reminders =>
        (cs.secondaryContainer, cs.onSecondaryContainer),
      MoreSearchKind.cards || MoreSearchKind.notes => (cs.tertiaryContainer, cs.onTertiaryContainer),
      MoreSearchKind.features => (cs.primaryContainer, cs.onPrimaryContainer),
      _ => (cs.surfaceContainerHigh, cs.onSurfaceVariant),
    };
    return KuberIconTile(icon: i.icon, glyph: 22, color: bg, iconColor: fg);
  }

  Widget _trailing(MoreSearchItem i, bool privacy, String symbol) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    if (i.amount != null) {
      if (privacy) {
        return Text(
          '$symbol ••••',
          style: theme.textTheme.titleMedium!.copyWith(color: cs.onSurfaceVariant, letterSpacing: 2),
        );
      }
      final money = context.kuberMoney;
      final (sign, color) = switch (i.tone) {
        MoreSearchTone.income => ('+', money.income),
        MoreSearchTone.expense => ('−', money.expense),
        MoreSearchTone.neutral => ('', cs.onSurface),
      };
      return Text(
        '$sign${i.amount}',
        style: theme.textTheme.titleMedium!.copyWith(color: color, fontFeatures: const [FontFeature.tabularFigures()]),
      );
    }
    if (i.kind == MoreSearchKind.cards) {
      return Icon(Icons.lock_outline_rounded, size: 18, color: cs.onSurfaceVariant);
    }
    return const KuberChevron();
  }

  Widget _row(MoreSearchItem i, bool privacy, String symbol) {
    final cs = Theme.of(context).colorScheme;
    return KuberSearchResultRow(
      key: ValueKey(i),
      leading: _leading(i, cs),
      title: i.title,
      query: _query.trim(),
      subtitle: privacy ? i.maskedSubtitle ?? i.subtitle : i.subtitle,
      matches: i.matches,
      trailing: _trailing(i, privacy, symbol),
      onTap: () => _open(i),
    );
  }

  Widget _group(int index, String title, List<MoreSearchItem> rows, Widget? action, bool privacy, String symbol) {
    final group = Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KuberSectionHeader(title: title, trailing: action),
          KuberGroup(children: [for (final r in rows) _row(r, privacy, symbol)]),
        ],
      ),
    );
    if (_risen) return group;
    return OnboardingEntrance(
      key: ValueKey('rise$index'),
      delay: Duration(milliseconds: 40 * index),
      duration: KuberMotion.fast,
      beginOffset: Offset.zero,
      rise: 8,
      child: group,
    );
  }

  List<Widget> _resultList(Map<MoreSearchKind, List<MoreSearchItem>> groups, bool privacy, String symbol) {
    final l = context.l10n;
    final out = <Widget>[];
    final filter = _filter;
    if (filter != null) {
      final rows = groups[filter] ?? const <MoreSearchItem>[];
      if (rows.isNotEmpty) {
        out.add(_group(0, '${rows.length} ${_kindName(filter, l)}', rows, null, privacy, symbol));
      }
    } else {
      var index = 0;
      for (final e in groups.entries) {
        final more = e.value.length > _groupRows;
        out.add(_group(
          index++,
          _kindName(e.key, l),
          e.value.take(_groupRows).toList(),
          more
              ? KuberSectionAction(
                  label: l.searchSeeAll('${e.value.length}'),
                  onTap: () => setState(() => _filter = e.key),
                )
              : null,
          privacy,
          symbol,
        ));
      }
    }
    if (groups.containsKey(MoreSearchKind.cards) || groups.containsKey(MoreSearchKind.notes)) {
      out.add(Padding(
        padding: const EdgeInsets.only(bottom: KuberSpace.xl),
        child: KuberInfoLine(icon: Icons.lock_outline_rounded, text: l.searchPrivateNote),
      ));
    }
    return out;
  }

  Widget _empty() {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return OnboardingEntrance(
      delay: const Duration(milliseconds: 100),
      duration: KuberMotion.fast,
      beginOffset: Offset.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_recents.isNotEmpty) ...[
            KuberSectionHeader(
              title: l.searchRecent,
              trailing: KuberSectionAction(label: l.searchClear, onTap: () => _setRecents(const [])),
            ),
            KuberGroup(
              children: [
                for (final r in _recents)
                  InkWell(
                    onTap: () => _search(r),
                    overlayColor: kuberPressedLayer(cs),
                    child: Container(
                      constraints: const BoxConstraints(minHeight: 52),
                      padding: const EdgeInsetsDirectional.only(start: KuberSpace.lg, end: KuberSpace.xs),
                      child: Row(
                        children: [
                          Icon(Icons.history_rounded, size: 20, color: cs.onSurfaceVariant),
                          const SizedBox(width: KuberSpace.lg),
                          Expanded(
                            child: Text(r, style: theme.textTheme.bodyLarge!.copyWith(color: cs.onSurface)),
                          ),
                          IconButton(
                            icon: Icon(Icons.close_rounded, size: 20, color: cs.onSurfaceVariant),
                            tooltip: l.searchClear,
                            onPressed: () => _setRecents(_recents.where((x) => x != r).toList()),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: KuberSpace.sectionGap),
          ],
          KuberSectionHeader(title: l.searchTry),
          Wrap(
            spacing: KuberSpace.sm,
            runSpacing: KuberSpace.sm,
            children: [
              for (final (icon, label, query) in [
                (Icons.dark_mode_outlined, l.searchTryDark, 'dark'),
                (Icons.pin_rounded, l.setNumberFormat, l.setNumberFormat),
                (Icons.backup_outlined, l.searchTryBackup, l.searchTryBackup),
                (Icons.credit_card_rounded, l.appDrawerCards, l.appDrawerCards),
                (Icons.handshake_outlined, l.menuLedger, l.menuLedger),
                (Icons.calculate_outlined, l.searchTryEmi, 'emi'),
              ])
                KuberChip(label: label, icon: icon, onTap: () => _search(query)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _noResults() {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final q = _query.trim();
    final words = q.split(RegExp(r'\s+'));
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 56 - 16, 12, 0),
      child: Column(
        children: [
          const KuberIconTile(
            icon: Icons.search_off_rounded,
            size: 64,
            glyph: 30,
            circle: true,
            tone: KuberTone.neutral,
          ),
          const SizedBox(height: KuberSpace.md),
          Text(l.searchNoResults(q),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge!.copyWith(color: cs.onSurface)),
          const SizedBox(height: KuberSpace.md),
          Text(l.searchNoResultsBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          if (words.length > 1) ...[
            const SizedBox(height: KuberSpace.lg),
            KuberChip(
              label: l.searchShorter(words.first),
              icon: Icons.search_rounded,
              onTap: () => _search(words.first),
            ),
          ],
          Padding(
            padding: const EdgeInsets.fromLTRB(0, KuberSpace.xl, 0, KuberSpace.lg),
            child: Divider(height: 1, color: cs.outlineVariant),
          ),
          Text(l.searchTransaction, style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: KuberSpace.md),
          AppButton(
            label: l.searchInHistory,
            height: 40,
            icon: Icons.receipt_long_rounded,
            onPressed: _toHistory,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final privacy = ref.watch(privacyModeProvider);
    final symbol = ref.watch(currencyProvider).symbol;
    final q = _query.trim();
    final groups = _results(l);
    final loading = q.isNotEmpty && _data == null;
    final results = _resultList(groups, privacy, symbol);
    final List<Widget> body;
    if (q.isEmpty) {
      body = [_empty()];
    } else if (loading && _slow) {
      body = results.isEmpty
          ? const [KuberSearchSkeleton(), KuberSearchSkeleton(rows: 2)]
          : [
              ...results,
              Padding(
                padding: const EdgeInsets.only(bottom: KuberSpace.lg),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: KuberSpace.sm),
                    Expanded(
                      child: Text(l.searchLoading,
                          style: theme.textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
                    ),
                  ],
                ),
              ),
              const KuberSearchSkeleton(),
            ];
    } else if (results.isEmpty) {
      body = loading ? const [] : [_noResults()];
    } else {
      body = results;
    }
    if (results.isNotEmpty && !_risen) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _risen = true);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
              child: _ExpandIn(
                child: KuberSearchPill(
                  controller: _controller,
                  hint: l.searchHint,
                  textInputAction: TextInputAction.done,
                  interceptBack: false,
                  backLabel: 'Back',
                  onChanged: _onChanged,
                  onClose: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            if (loading && _slow)
              const Padding(
                padding: EdgeInsets.fromLTRB(KuberSpace.screenMargin, 0, KuberSpace.screenMargin, KuberSpace.sm),
                child: KuberLinearProgress(value: 0.38),
              ),
            OnboardingEntrance(
              delay: const Duration(milliseconds: 100),
              duration: KuberMotion.fast,
              beginOffset: Offset.zero,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Row(
                  children: [
                    KuberChip(
                      label: l.searchAll,
                      selected: _filter == null,
                      onTap: () => setState(() => _filter = null),
                    ),
                    for (final k in MoreSearchKind.values) ...[
                      const SizedBox(width: KuberSpace.sm),
                      KuberChip(
                        label: _kindName(k, l),
                        selected: _filter == k,
                        onTap: () => setState(() => _filter = _filter == k ? null : k),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Expanded(
              child: AnimatedSwitcher(
                duration: KuberMotion.of(context, KuberMotion.fast),
                child: ListView(
                  key: ValueKey(_filter),
                  keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpace.screenMargin,
                    0,
                    KuberSpace.screenMargin,
                    KuberSpace.xl,
                  ),
                  children: body,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// One-shot entrance: the pill grows from the trailing edge (where the More
/// header's search icon sits) to full width. Reduced motion: fade only.
class _ExpandIn extends StatelessWidget {
  final Widget child;
  const _ExpandIn({required this.child});

  @override
  Widget build(BuildContext context) {
    final reduced = KuberMotion.reduced(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: reduced
          ? KuberMotion.reducedFade
          : const Duration(milliseconds: 300),
      curve: reduced ? Curves.linear : Curves.easeInOutCubicEmphasized,
      child: child,
      builder: (_, t, c) => Opacity(
        opacity: t.clamp(0, 1),
        child: reduced
            ? c
            : ClipRect(
                child: Align(
                  alignment: AlignmentDirectional.centerEnd,
                  widthFactor: t.clamp(0, 1),
                  child: c,
                ),
              ),
      ),
    );
  }
}
