import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../core/models/info_config.dart';
import '../utils/quick_add_parser.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';

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

  void _openFullScreen({bool voice = false}) {
    final text = _controller.text.trim();
    final uri = Uri(
      path: '/quick-add',
      queryParameters: {
        if (text.isNotEmpty) 'text': text,
        if (voice) 'voice': 'true',
      },
    );
    context.push(uri.toString());
  }

  Future<void> _submit([String? override]) async {
    final l10n = context.l10n;
    final input = (override ?? _controller.text).trim();
    if (input.isEmpty) return;

    final parsed = parseQuickAdd(input);

    if (parsed.amount == null || parsed.amount! <= 0) {
      setState(() => _error = l10n.quickAddInvalidAmount);
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
      if (match != null) {
        resolvedAccountId = match.id.toString();
      } else {
        setState(() {
          _error = l10n.quickAddNoAccountNamed(parsed.accountHint!);
          _isLoading = false;
        });
        return;
      }
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

    if (resolvedCategory == null) {
      if (mounted) {
        setState(() {
          _error = l10n.quickAddCouldNotResolveCategory;
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
      ..quickAddNote = input
      ..importSource = 'quick_add'
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
      l10n.quickAddAdded('$symbol$amountStr', resolvedCategory.name),
    );
    _controller.clear();
    setState(() => _isLoading = false);
  }

  void _showNoAccountDialog(String? hint) {
    final cs = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surface,
        title: Text(l10n.noAccountFoundTitle,
            style: localeFont(fontWeight: FontWeight.w700)),
        content: Text(
          hint != null
              ? l10n.noAccountMatchedBody(hint)
              : l10n.noDefaultAccountBody,
          style: localeFont(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancelLabel, style: localeFont()),
          ),
          AppButton(
            label: l10n.openSettings,
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
        KuberHomeWidgetTitle(
          title: context.l10n.quickAddTitle,
          trailing: GestureDetector(
            onTap: () => _openFullScreen(),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Full screen',
                  style: localeFont(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.open_in_full_rounded,
                  size: 14,
                  color: cs.primary,
                ),
              ],
            ),
          ),
          infoConfig: KuberInfoConfig(
            title: context.l10n.quickAddInfoTitle,
            description: context.l10n.quickAddInfoDesc,
            items: [
              KuberInfoItem(
                icon: Icons.flash_on_rounded,
                title: context.l10n.quickAddBasicAmount,
                description: context.l10n.quickAddBasicAmountDesc,
              ),
              KuberInfoItem(
                icon: Icons.category_outlined,
                title: context.l10n.quickAddWithCategory,
                description: context.l10n.quickAddWithCategoryDesc,
              ),
              KuberInfoItem(
                icon: Icons.account_balance_wallet_rounded,
                title: context.l10n.quickAddWithAccount,
                description: context.l10n.quickAddWithAccountDesc,
              ),
              KuberInfoItem(
                icon: Icons.auto_fix_high_rounded,
                title: context.l10n.quickAddActionWords,
                description: context.l10n.quickAddActionWordsDesc,
              ),
              KuberInfoItem(
                icon: Icons.star_outline_rounded,
                title: context.l10n.quickAddDefaultAccountInfo,
                description: context.l10n.quickAddDefaultAccountInfoDesc,
              ),
            ],
          ),
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
                  style: localeFont(fontSize: 15, color: cs.onSurface),
                  onTapOutside: (_) {
                    FocusManager.instance.primaryFocus?.unfocus();
                  },
                  decoration: InputDecoration(
                    hintText: context.l10n.quickAddHint,
                    hintStyle: localeFont(
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
              // Voice Button (52 wide, surfaceContainerHigh, border, KuberRadius.md)
              GestureDetector(
                onTap: () => _openFullScreen(voice: true),
                child: Container(
                  width: 52,
                  decoration: BoxDecoration(
                    color: cs.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(KuberRadius.md),
                    border: Border.all(color: cs.outline),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.mic_none_rounded,
                      size: 22,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              // Send button
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: _controller,
                builder: (context, value, child) {
                  final isEmpty = value.text.trim().isEmpty;
                  final isActive = !isEmpty || _isLoading;

                  return GestureDetector(
                    onTap: (_isLoading || isEmpty) ? null : _submit,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      decoration: BoxDecoration(
                        color: isActive
                            ? cs.primary
                            : cs.onSurfaceVariant.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Center(
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: _isLoading
                              ? SizedBox(
                                  key: const ValueKey('spinner'),
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: cs.onPrimary,
                                  ),
                                )
                              : Icon(
                                  key: const ValueKey('icon'),
                                  Icons.send_rounded,
                                  size: 22,
                                  color: isActive
                                      ? cs.onPrimary
                                      : cs.onSurfaceVariant.withValues(alpha: 0.5),
                                ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        // Non-tappable example chips below input
        const SizedBox(height: KuberSpacing.sm),
        IgnorePointer(
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              _buildExampleChip(cs, 'Try: "300 movies and 500 dinner"'),
              _buildExampleChip(cs, '"1200 rent from HDFC"'),
            ],
          ),
        ),
        if (_error != null) ...[
          const SizedBox(height: KuberSpacing.sm),
          Text(
            _error!,
            style: localeFont(fontSize: 12, color: cs.error),
          ),
        ],
      ],
    );
  }

  Widget _buildExampleChip(ColorScheme cs, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: cs.outline),
      ),
      child: Text(
        text,
        style: localeFont(
          fontSize: 11.5,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}