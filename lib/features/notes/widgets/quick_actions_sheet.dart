import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/settings_provider.dart' show formatterProvider;

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

  String get _amountParam => amount == amount.truncateToDouble()
      ? amount.toInt().toString()
      : amount.toStringAsFixed(2);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final formatted = ref.watch(formatterProvider).formatCurrency(amount.abs());
    final catParam = inheritedCategoryId != null
        ? '&categoryId=$inheritedCategoryId'
        : '';

    final tt = Theme.of(context).textTheme;
    Widget row(IconData icon, String label, VoidCallback onTap) => KuberListRow(
      leading: KuberIconTile(icon: icon),
      title: label,
      trailing: const KuberChevron(),
      onTap: onTap,
    );

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ClipRRect(
        borderRadius: KuberShape.sheetR,
        child: ColoredBox(
          color: cs.surfaceContainerLow,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpace.screenMargin,
                0,
                KuberSpace.screenMargin,
                KuberSpace.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      width: 32,
                      height: 4,
                      decoration: BoxDecoration(
                        color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                        borderRadius: KuberShape.fullR,
                      ),
                    ),
                  ),
                  Text(
                    'Tapped from note: $noteTitle',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: tt.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatted,
                    style: tt.headlineMedium!.copyWith(color: cs.onSurface),
                  ),
                  const SizedBox(height: KuberSpace.lg),
                  KuberGroup(
                    children: [
                      row(
                        Icons.add_rounded,
                        'Add as Transaction',
                        () => _go(
                          context,
                          '/add-transaction?amount=$_amountParam'
                          '&sourceNoteId=$fromNoteId$catParam',
                        ),
                      ),
                      row(
                        Icons.repeat_rounded,
                        'Add as Recurring',
                        () => _go(
                          context,
                          '/recurring/add?amount=$_amountParam$catParam',
                        ),
                      ),
                      row(
                        Icons.trending_up_rounded,
                        'Add as Investment',
                        () => _go(
                          context,
                          '/investments/add?amount=$_amountParam',
                        ),
                      ),
                      row(
                        Icons.account_balance_rounded,
                        'Add as Loan',
                        () => _go(context, '/loans/add?amount=$_amountParam'),
                      ),
                      row(
                        Icons.swap_horiz_rounded,
                        'Add to Lent / Borrow',
                        () => _go(context, '/ledger/add?amount=$_amountParam'),
                      ),
                    ],
                  ),
                  const SizedBox(height: KuberSpace.md),
                  AppButton(
                    label: 'Copy amount',
                    icon: Icons.copy_rounded,
                    type: AppButtonType.outline,
                    fullWidth: true,
                    onPressed: () async {
                      await Clipboard.setData(
                        ClipboardData(text: _amountParam),
                      );
                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                        showKuberSnackBar(context, 'Amount copied');
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
