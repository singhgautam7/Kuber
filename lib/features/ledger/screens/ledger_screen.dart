import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_page_header.dart';
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
              const SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  showHome: true,
                  title: '',
                  infoConfig: InfoConstants.ledger,
                ),
              ),
              SliverToBoxAdapter(
                child: KuberPageHeader(
                  title: context.l10n.lentBorrowedTitle,
                  description: '',
                  actionTooltip: context.l10n.addEntry,
                  onAction: () => context.push('/ledger/add'),
                ),
              ),
              if (ledgers.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpacing.lg,
                    0,
                    KuberSpacing.lg,
                    KuberSpacing.md,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: LedgerHero(
                      toReceive: toReceive,
                      owed: owed,
                      receiveCount: receiveCount,
                      oweCount: oweCount,
                    ),
                  ),
                ),
              if (ledgers.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                  ),
                  sliver: SliverToBoxAdapter(
                    child: _FilterRow(
                      selected: _filterType,
                      onChanged: (v) => setState(() => _filterType = v),
                    ),
                  ),
                ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.handshake_outlined,
                    title: context.l10n.noLedgerEntries,
                    description: context.l10n.ledgerEmptyDesc,
                    actionLabel: context.l10n.addEntry,
                    onAction: () => context.push('/ledger/add'),
                  ),
                ),
              if (active.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                  ),
                  sliver: SliverList.separated(
                    itemCount: active.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: KuberSpacing.sm),
                    itemBuilder: (_, i) =>
                        _LedgerRow(ledger: active[i], allTxns: allTxns),
                  ),
                ),
              if (settled.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(label: context.l10n.settledUpper),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.lg,
                  ),
                  sliver: SliverList.separated(
                    itemCount: settled.length,
                    separatorBuilder: (_, __) =>
                        const SizedBox(height: KuberSpacing.sm),
                    itemBuilder: (_, i) =>
                        _LedgerRow(ledger: settled[i], allTxns: allTxns),
                  ),
                ),
              ],
              SliverToBoxAdapter(
                child: SizedBox(height: navBarBottomPadding(context)),
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

class _FilterRow extends StatelessWidget {
  final String? selected;
  final ValueChanged<String?> onChanged;

  const _FilterRow({required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final hasFilter = selected != null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Text(
              context.l10n.filtersUpper,
              style: localeFont(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const Spacer(),
            _FilterChip(
              label: context.l10n.lentLabel,
              isSelected: selected == 'lent',
              onTap: () => onChanged(selected == 'lent' ? null : 'lent'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: context.l10n.borrowedLabel,
              isSelected: selected == 'borrowed',
              onTap: () =>
                  onChanged(selected == 'borrowed' ? null : 'borrowed'),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: hasFilter ? () => onChanged(null) : null,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: hasFilter ? 1.0 : 0.3,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: hasFilter
                        ? Border.all(color: cs.error.withValues(alpha: 0.5))
                        : null,
                  ),
                  child: Icon(
                    Icons.delete_sweep_rounded,
                    size: 20,
                    color: hasFilter ? cs.error : cs.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary : cs.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: localeFont(
            fontSize: 13,
            fontWeight: FontWeight.w800,
            color: isSelected ? Colors.white : cs.onSurfaceVariant,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KuberSpacing.lg,
        KuberSpacing.sm,
        KuberSpacing.lg,
        KuberSpacing.md,
      ),
      child: Text(
        label,
        style: localeFont(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}