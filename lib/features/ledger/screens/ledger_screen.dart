import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_extended_fab.dart';
import '../../settings/providers/info_provider.dart';
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../data/ledger.dart';
import '../providers/ledger_provider.dart';
import '../utils/ledger_calculations.dart' as calc;
import '../widgets/ledger_detail_sheet.dart';
import '../widgets/ledger_widgets.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  String? _filterType;
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoLedger), (
      prev,
      next,
    ) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.ledger);
          ref
              .read(infoSeenProvider(PrefsKeys.seenInfoLedger).notifier)
              .markSeen();
        });
      }
    });

    final cs = Theme.of(context).colorScheme;
    final ledgersAsync = ref.watch(ledgerListProvider);
    final txnsAsync = ref.watch(transactionListProvider);

    return Scaffold(
      floatingActionButton: KuberExtendedFab(
        icon: Icons.add_rounded,
        label: context.l10n.addEntry,
        onPressed: () => context.push('/ledger/add'),
      ),
      floatingActionButtonLocation: kuberFabLocation,
      body: ledgersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            context.l10n.errorWithDetails(e.toString()),
            style: localeFont(color: cs.onSurfaceVariant),
          ),
        ),
        data: (ledgers) {
          final allTxns = txnsAsync.valueOrNull ?? [];
          var filtered = ledgers;
          if (_filterType != null) {
            filtered = ledgers.where((l) => l.type == _filterType).toList();
          }
          // Header search: person name or notes; the hero hides meanwhile.
          final q = _query.trim().toLowerCase();
          if (q.isNotEmpty) {
            filtered = [
              for (final l in filtered)
                if (l.personNameLower.contains(q) ||
                    (l.notes?.toLowerCase().contains(q) ?? false))
                  l,
            ];
          }
          final active = filtered.where((l) => !l.isSettled).toList();
          final settled = filtered.where((l) => l.isSettled).toList();
          final toReceive = calc.totalToReceive(ledgers, allTxns);
          final owed = calc.totalOwed(ledgers, allTxns);
          final receiveCount = ledgers
              .where((l) => l.type == 'lent' && !l.isSettled)
              .map((l) => l.personName)
              .toSet()
              .length;
          final oweCount = ledgers
              .where((l) => l.type == 'borrowed' && !l.isSettled)
              .map((l) => l.personName)
              .toSet()
              .length;

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  title: context.l10n.ledgerTitle,
                  infoConfig: InfoConstants.ledger,
                  search: ledgers.isEmpty
                      ? null
                      : KuberHeaderSearch(
                          controller: _searchController,
                          hint: context.l10n.searchLedgerHint,
                          onChanged: (v) => setState(() => _query = v),
                        ),
                ),
              ),

              if (ledgers.isNotEmpty && q.isEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpace.screenMargin,
                    0,
                    KuberSpace.screenMargin,
                    KuberSpace.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: LedgerHero(
                      toReceive: toReceive,
                      owed: owed,
                      receiveCount: receiveCount,
                      oweCount: oweCount,
                      activeEntries: ledgers.where((l) => !l.isSettled).length,
                      peopleCount: ledgers
                          .where((l) => !l.isSettled)
                          .map((l) => l.personNameLower)
                          .toSet()
                          .length,
                    ),
                  ),
                ),
              if (ledgers.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpace.screenMargin,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _FilterRow(
                      selected: _filterType,
                      onChanged: (v) => setState(() => _filterType = v),
                    ),
                  ),
                ),
              if (filtered.isEmpty && q.isNotEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.search_off_rounded,
                    title: context.l10n.noMatches,
                    description: context.l10n.nothingMatchesQuery(
                      _query.trim(),
                    ),
                  ),
                )
              else if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.handshake_outlined,
                    title: context.l10n.noLedgerEntries,
                    description: context.l10n.ledgerEmptyDesc,
                  ),
                ),
              // Board 3.20: Active and Settled as grouped lists.
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpace.screenMargin,
                ),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (active.isNotEmpty) ...[
                        KuberSectionHeader(title: context.l10n.activeUpper),
                        KuberGroup(
                          children: [
                            for (final l in active)
                              _LedgerRow(ledger: l, allTxns: allTxns),
                          ],
                        ),
                      ],
                      if (settled.isNotEmpty) ...[
                        const SizedBox(height: KuberSpace.sectionGap),
                        KuberSectionHeader(title: context.l10n.settledUpper),
                        KuberGroup(
                          children: [
                            for (final l in settled)
                              _LedgerRow(ledger: l, allTxns: allTxns),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: KuberExtendedFab.clearance),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LedgerRow extends StatelessWidget {
  final Ledger ledger;
  final List<Transaction> allTxns;

  const _LedgerRow({required this.ledger, required this.allTxns});

  @override
  Widget build(BuildContext context) {
    return LedgerEntryCard(
      personName: ledger.personName,
      type: ledger.type == 'lent'
          ? LedgerEntryType.lent
          : LedgerEntryType.borrowed,
      isSettled: ledger.isSettled,
      originalAmount: ledger.originalAmount,
      paid: calc.computePaid(ledger.uid, allTxns),
      remaining: calc
          .computeRemaining(ledger, allTxns)
          .clamp(0, double.infinity)
          .toDouble(),
      progress: calc.computeProgress(ledger, allTxns),
      expectedDate: ledger.expectedDate,
      settledAt: ledger.isSettled ? ledger.updatedAt : null,
      onTap: () {
        showModalBottomSheet(
          context: context,
          useRootNavigator: true,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) => LedgerDetailSheet(ledger: ledger),
        );
      },
    );
  }
}

/// Lent / Borrowed filter chips (board 3.20: no FILTERS label; tapping the
/// selected chip again clears it).
class _FilterRow extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _FilterRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sm),
      child: Wrap(
        spacing: KuberSpace.sm,
        children: [
          KuberChip(
            label: context.l10n.lentLabel,
            selected: selected == 'lent',
            onTap: () => onChanged(selected == 'lent' ? null : 'lent'),
          ),
          KuberChip(
            label: context.l10n.borrowedLabel,
            selected: selected == 'borrowed',
            onTap: () => onChanged(selected == 'borrowed' ? null : 'borrowed'),
          ),
        ],
      ),
    );
  }
}
