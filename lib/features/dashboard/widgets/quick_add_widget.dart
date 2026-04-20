import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/data/category.dart';
import '../../categories/providers/category_provider.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider, settingsProvider;
import '../../transactions/data/transaction.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_info_bottom_sheet.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../core/models/info_config.dart';
import '../utils/quick_add_parser.dart';

class QuickAddWidget extends ConsumerStatefulWidget {
  const QuickAddWidget({super.key});

  @override
  ConsumerState<QuickAddWidget> createState() => _QuickAddWidgetState();
}

class _QuickAddWidgetState extends ConsumerState<QuickAddWidget> {
  final _controller = TextEditingController();
  String? _error;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit([String? override]) async {
    final input = (override ?? _controller.text).trim();
    if (input.isEmpty) return;

    final parsed = parseQuickAdd(input);

    if (parsed.amount == null || parsed.amount! <= 0) {
      setState(() => _error = 'Enter a valid amount (e.g. 200 on coffee)');
      return;
    }
    setState(() {
      _error = null;
      _isLoading = true;
    });

    final accounts = ref.read(accountListProvider).valueOrNull ?? [];
    final settings = await ref.read(settingsProvider.future);
    final defaultId = settings.defaultAccountId;

    // Resolve account
    String? resolvedAccountId;
    if (parsed.accountHint != null) {
      final hint = parsed.accountHint!.toLowerCase();
      final match =
          accounts.where((a) => a.name.toLowerCase().contains(hint)).firstOrNull;
      if (match != null) resolvedAccountId = match.id.toString();
    }
    resolvedAccountId ??= defaultId;

    if (resolvedAccountId == null) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      _showNoAccountDialog(parsed.accountHint);
      return;
    }

    // Resolve or create category
    final catHint = (parsed.category ?? '').toLowerCase().trim();
    var categories = ref.read(categoryListProvider).valueOrNull ?? [];

    Category? resolvedCategory;
    if (catHint.isNotEmpty) {
      resolvedCategory =
          categories.where((c) => c.name.toLowerCase().contains(catHint)).firstOrNull;
    }
    resolvedCategory ??= categories
        .where((c) =>
            c.name.toLowerCase() == 'general' ||
            c.name.toLowerCase() == 'other')
        .firstOrNull;

    if (resolvedCategory == null && catHint.isNotEmpty) {
      final newCat = Category()
        ..name = catHint.toTitleCase()
        ..icon = 'circle'
        ..colorValue = 0xFF6B7280
        ..type = 'expense';
      await ref.read(categoryListProvider.notifier).add(newCat);
      categories = await ref.read(categoryListProvider.future);
      resolvedCategory = categories
          .where((c) => c.name.toLowerCase() == catHint.toLowerCase())
          .firstOrNull;
    }

    if (resolvedCategory == null) {
      if (mounted) {
        setState(() {
          _error = 'Could not resolve category';
          _isLoading = false;
        });
      }
      return;
    }

    // Save transaction
    final name = parsed.category != null
        ? parsed.category!.toTitleCase()
        : 'Quick Add';
    final txn = Transaction()
      ..name = name
      ..nameLower = name.toLowerCase()
      ..amount = parsed.amount!
      ..type = 'expense'
      ..categoryId = resolvedCategory.id.toString()
      ..accountId = resolvedAccountId
      ..createdAt = DateTime.now()
      ..updatedAt = DateTime.now();

    await ref.read(transactionListProvider.notifier).add(txn);

    if (!mounted) return;
    final symbol = ref.read(currencyProvider).symbol;
    final amountStr = parsed.amount! % 1 == 0
        ? parsed.amount!.toInt().toString()
        : parsed.amount!.toStringAsFixed(2);

    showKuberSnackBar(
      context,
      '$symbol$amountStr added to ${resolvedCategory.name}',
    );
    _controller.clear();
    setState(() => _isLoading = false);
  }

  void _showNoAccountDialog(String? hint) {
    final cs = Theme.of(context).colorScheme;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text('No account found',
            style: GoogleFonts.inter(fontWeight: FontWeight.w700)),
        content: Text(
          hint != null
              ? 'No account matched "$hint" and no default account is set.'
                  ' Set a default account in Settings to use Quick Add.'
              : 'No default account is set. Set one in Settings to use Quick Add.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          AppButton(
            label: 'Open Settings',
            type: AppButtonType.primary,
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/more/settings');
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'QUICK ADD',
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                KuberInfoBottomSheet.show(
                  context,
                  const KuberInfoConfig(
                    title: 'Quick Add',
                    description: 'Quickly record an expense using natural language without jumping through forms. It intelligently extracts the amount, category, and account.',
                    items: [
                      KuberInfoItem(
                        icon: Icons.flash_on_rounded,
                        title: 'Basic Expense',
                        description: 'Type "250 on food" to add an expense of 250 to Food.',
                      ),
                      KuberInfoItem(
                        icon: Icons.account_balance_wallet_rounded,
                        title: 'With Account',
                        description: 'Type "150 for uber from hdfc" to charge 150 to the HDFC account.',
                      ),
                    ],
                  ),
                );
              },
              child: Icon(
                Icons.help_outline_rounded,
                size: 15,
                color: cs.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
        const SizedBox(height: KuberSpacing.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  enabled: !_isLoading,
                  style: GoogleFonts.inter(fontSize: 15, color: cs.onSurface),
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: 'e.g. 250 on groceries from HDFC',
                    hintStyle: GoogleFonts.inter(
                        fontSize: 15,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.6)),
                  ),
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) {
                    if (_controller.text.trim().isNotEmpty) _submit();
                  },
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  final isEmpty = value.text.trim().isEmpty;
                  final isDisabled = _isLoading || isEmpty;

                  return GestureDetector(
                    onTap: isDisabled ? null : _submit,
                    child: Container(
                      width: 52,
                      decoration: BoxDecoration(
                        color: isDisabled
                            ? cs.onSurfaceVariant.withValues(alpha: 0.2)
                            : cs.primary,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Center(
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: cs.onSurfaceVariant,
                                ),
                              )
                            : Icon(
                                Icons.send_rounded,
                                size: 22,
                                color: isDisabled
                                    ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                                    : cs.onPrimary,
                              ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: KuberSpacing.sm),
          Text(
            _error!,
            style: GoogleFonts.inter(fontSize: 12, color: cs.error),
          ),
        ],
      ],
    );
  }
}
