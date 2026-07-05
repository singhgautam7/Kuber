import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/settings_provider.dart'
    show formatterProvider;

/// Bottom sheet shown when a highlighted number (or resolved arithmetic
/// result) is tapped in the Notes editor (screen 1g).
class QuickActionsSheet extends ConsumerWidget {
  final double amount;
  final String noteTitle;
  final int fromNoteId;
  final String? inheritedCategoryId;

  const QuickActionsSheet({
    super.key,
    required this.amount,
    required this.noteTitle,
    required this.fromNoteId,
    this.inheritedCategoryId,
  });

  static void show(
    BuildContext context, {
    required double amount,
    required String noteTitle,
    required int fromNoteId,
    String? inheritedCategoryId,
  }) {
    showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) => QuickActionsSheet(
        amount: amount,
        noteTitle: noteTitle,
        fromNoteId: fromNoteId,
        inheritedCategoryId: inheritedCategoryId,
      ),
    );
  }

  void _go(BuildContext context, String location) {
    Navigator.of(context, rootNavigator: true).pop();
    context.push(location);
  }

  String get _amountParam =>
      amount == amount.truncateToDouble()
          ? amount.toInt().toString()
          : amount.toStringAsFixed(2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatted = ref.watch(formatterProvider).formatCurrency(amount.abs());
    final catParam = inheritedCategoryId != null
        ? '&categoryId=$inheritedCategoryId'
        : '';

    return Container(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius:
            const BorderRadius.vertical(top: Radius.circular(KuberRadius.lg)),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 12, bottom: 4),
              child: Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
            // Header: amount + note context
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 12, 22, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    formatted,
                    style: localeFont(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Tapped from note: $noteTitle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, thickness: 1, color: cs.outline),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 20),
              child: Column(
                children: [
                  _ActionRow(
                    icon: Icons.add_rounded,
                    label: 'Add as Transaction',
                    onTap: () => _go(
                      context,
                      '/add-transaction?amount=$_amountParam'
                      '&sourceNoteId=$fromNoteId$catParam',
                    ),
                  ),
                  _ActionRow(
                    icon: Icons.repeat_rounded,
                    label: 'Add as Recurring',
                    onTap: () => _go(context,
                        '/recurring/add?amount=$_amountParam$catParam'),
                  ),
                  _ActionRow(
                    icon: Icons.trending_up_rounded,
                    label: 'Add as Investment',
                    onTap: () =>
                        _go(context, '/investments/add?amount=$_amountParam'),
                  ),
                  _ActionRow(
                    icon: Icons.account_balance_rounded,
                    label: 'Add as Loan',
                    onTap: () => _go(context, '/loans/add?amount=$_amountParam'),
                  ),
                  _ActionRow(
                    icon: Icons.swap_horiz_rounded,
                    label: 'Add to Lent / Borrow',
                    onTap: () =>
                        _go(context, '/ledger/add?amount=$_amountParam'),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    child:
                        Divider(height: 1, thickness: 1, color: cs.outline),
                  ),
                  // Copy amount — muted, no chevron
                  InkWell(
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    onTap: () async {
                      await Clipboard.setData(
                          ClipboardData(text: _amountParam));
                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                        showKuberSnackBar(context, 'Amount copied');
                      }
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 11),
                      child: Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: cs.surfaceContainerHigh,
                              borderRadius:
                                  BorderRadius.circular(KuberRadius.md),
                              border: Border.all(color: cs.outline),
                            ),
                            child: Icon(Icons.copy_rounded,
                                size: 18, color: cs.onSurfaceVariant),
                          ),
                          const SizedBox(width: 13),
                          Text(
                            'Copy amount',
                            style: localeFont(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border:
                    Border.all(color: cs.primary.withValues(alpha: 0.28)),
              ),
              child: Icon(icon, size: 19, color: cs.primary),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(
                label,
                style: localeFont(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                size: 18, color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
          ],
        ),
      ),
    );
  }
}
