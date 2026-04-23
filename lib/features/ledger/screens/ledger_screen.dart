import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/info_constants.dart';
import '../../../core/theme/app_theme.dart';
import '../../transactions/data/transaction.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../settings/providers/info_provider.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider, privacyModeProvider;
import '../../transactions/providers/transaction_provider.dart';
import '../data/ledger.dart';
import '../providers/ledger_provider.dart';
import '../utils/ledger_calculations.dart' as calc;
import '../widgets/ledger_detail_sheet.dart';

class LedgerScreen extends ConsumerStatefulWidget {
  const LedgerScreen({super.key});

  @override
  ConsumerState<LedgerScreen> createState() => _LedgerScreenState();
}

class _LedgerScreenState extends ConsumerState<LedgerScreen> {
  String? _filterType; // null = all, 'lent', 'borrowed'

  @override


  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<bool>>(infoSeenProvider(PrefsKeys.seenInfoLedger), (prev, next) {
      if (next.hasValue && next.value == false) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          KuberInfoBottomSheet.show(context, InfoConstants.ledger);
          ref.read(infoSeenProvider(PrefsKeys.seenInfoLedger).notifier).markSeen();
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
          child: Text('Error: $e',
              style: GoogleFonts.inter(color: cs.onSurfaceVariant)),
        ),
        data: (ledgers) {
          final allTxns = txnsAsync.valueOrNull ?? [];

          // Apply filter
          var filtered = ledgers;
          if (_filterType != null) {
            filtered = ledgers.where((l) => l.type == _filterType).toList();
          }

          final active = filtered.where((l) => !l.isSettled).toList();
          final settled = filtered.where((l) => l.isSettled).toList();

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  title: 'Lent / Borrow',
                  infoConfig: InfoConstants.ledger,
                ),
              ),
              SliverToBoxAdapter(
                child: KuberPageHeader(
                  title: 'Lent &\nBorrowed',
                  description: 'Track money owed to and by you.',
                  actionTooltip: 'Add Entry',
                  onAction: () => context.push('/ledger/add'),
                ),
              ),

              // Summary cards
              if (ledgers.isNotEmpty)
                SliverToBoxAdapter(
                  child: _SummaryRow(ledgers: ledgers, allTxns: allTxns),
                ),

              // Filter row
              if (ledgers.isNotEmpty)
                SliverToBoxAdapter(
                  child: _FilterRow(
                    selected: _filterType,
                    onChanged: (v) => setState(() => _filterType = v),
                  ),
                ),

              // Empty state
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: KuberEmptyState(
                    icon: Icons.handshake_outlined,
                    title: 'No ledger entries yet',
                    description: 'Tap + to record a lend or borrow',
                    actionLabel: 'Add Entry',
                    onAction: () => context.push('/ledger/add'),
                  ),
                ),

              // Active section
              if (active.isNotEmpty) ...[
                // SliverToBoxAdapter(
                //   child: _SectionHeader(label: 'ACTIVE LEDGER'),
                // ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: active.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _LedgerCard(
                      ledger: active[i],
                      allTxns: allTxns,
                    ),
                  ),
                ),
              ],

              // Settled section
              if (settled.isNotEmpty) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(label: 'SETTLED'),
                ),
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.separated(
                    itemCount: settled.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (_, i) => _LedgerCard(
                      ledger: settled[i],
                      allTxns: allTxns,
                    ),
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

class _SummaryRow extends ConsumerWidget {
  final List<Ledger> ledgers;
  final List<Transaction> allTxns;

  const _SummaryRow({required this.ledgers, required this.allTxns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final toReceive = calc.totalToReceive(ledgers, allTxns);
    final owed = calc.totalOwed(ledgers, allTxns);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        children: [
          Expanded(
            child: _SummaryCard(
              label: 'YOU WILL RECEIVE',
              amount: maskAmount(fmt.formatCurrency(toReceive), isPrivate),
              color: cs.tertiary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SummaryCard(
              label: 'YOU OWE',
              amount: maskAmount(fmt.formatCurrency(owed), isPrivate),
              color: cs.error,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _SummaryCard({
    required this.label,
    required this.amount,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
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
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SizedBox(
        height: 48,
        child: Row(
          children: [
            Text(
              'FILTERS',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const Spacer(),
            _FilterChip(
              label: 'Lent',
              isSelected: selected == 'lent',
              onTap: () => onChanged(selected == 'lent' ? null : 'lent'),
            ),
            const SizedBox(width: 8),
            _FilterChip(
              label: 'Borrowed',
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
          style: GoogleFonts.inter(
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
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Text(
        label,
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: cs.onSurfaceVariant,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _LedgerCard extends ConsumerWidget {
  final Ledger ledger;
  final List<Transaction> allTxns;

  const _LedgerCard({required this.ledger, required this.allTxns});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final fmt = ref.watch(formatterProvider);
    final isPrivate = ref.watch(privacyModeProvider);

    final paid = calc.computePaid(ledger.uid, allTxns);
    final remaining = calc.computeRemaining(ledger, allTxns);
    final progress = calc.computeProgress(ledger, allTxns);
    final isLent = ledger.type == 'lent';
    final isSettled = ledger.isSettled;
    final progressColor = isSettled
        ? cs.onSurfaceVariant
        : (isLent ? cs.tertiary : cs.error);
    final initials = _getInitials(ledger.personName);

    return GestureDetector(
      onTap: () => _openDetailSheet(context, ledger),
      child: Opacity(
        opacity: isSettled ? 0.55 : 1.0,
        child: Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
          ),
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              // Top row
              Row(
                children: [
                  // Avatar
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerHighest,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initials,
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Name + type badge
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ledger.personName,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSettled
                                ? cs.onSurfaceVariant.withValues(alpha: 0.12)
                                : (isLent ? cs.primary : cs.error)
                                    .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            isSettled
                                ? 'SETTLED'
                                : (isLent ? 'LENT' : 'BORROWED'),
                            style: GoogleFonts.inter(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: isSettled
                                  ? cs.onSurfaceVariant
                                  : (isLent ? cs.primary : cs.error),
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Amount
                  Text(
                    maskAmount(fmt.formatCurrency(ledger.originalAmount), isPrivate),
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      decoration:
                          isSettled ? TextDecoration.lineThrough : null,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Second row: date + paid
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isSettled
                        ? 'SETTLED: ${DateFormat('MMM d').format(ledger.updatedAt).toUpperCase()}'
                        : ledger.expectedDate != null
                            ? 'DUE: ${DateFormat('MMM d').format(ledger.expectedDate!).toUpperCase()}'
                            : 'NO DUE DATE',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.6,
                    ),
                  ),
                  Text(
                    'Paid: ${maskAmount(fmt.formatCurrency(paid), isPrivate)}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 4,
                  backgroundColor: cs.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation(progressColor),
                ),
              ),

              const SizedBox(height: 6),

              // Bottom row: remaining + percentage
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'REMAINING: ${maskAmount(fmt.formatCurrency(remaining.clamp(0, double.infinity)), isPrivate)}',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.4,
                    ),
                  ),
                  if (isSettled)
                    Icon(Icons.check_circle, size: 16, color: cs.onSurfaceVariant)
                  else
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: progress > 0 ? cs.tertiary : cs.error,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openDetailSheet(BuildContext context, Ledger ledger) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LedgerDetailSheet(ledger: ledger),
    );
  }

  String _getInitials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : '?';
  }
}
