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
import '../../quick_add/services/quick_add_parser.dart';
import '../../../core/utils/fuzzy_category_matcher.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_list.dart';

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
    final l10n = context.l10n;
    final input = (override ?? _controller.text).trim();
    if (input.isEmpty) return;

    final parsed = parseQuickAddSingle(input);

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
      final match = accounts
          .where((a) => a.name.toLowerCase().contains(hint))
          .firstOrNull;
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

    // Resolve or create category. Fuzzy match against the user's real
    // categories (normalized, singular/plural aware) — never creates a
    // duplicate of an existing one.
    final catHint = parsed.categoryHint?.trim() ?? '';
    var categories = ref.read(categoryListProvider).valueOrNull ?? [];

    Category? resolvedCategory;
    if (catHint.isNotEmpty) {
      resolvedCategory = matchCategory(catHint, categories, type: parsed.type);
    }
    resolvedCategory ??= categories
        .where(
          (c) =>
              c.name.toLowerCase() == 'general' ||
              c.name.toLowerCase() == 'other',
        )
        .firstOrNull;

    if (resolvedCategory == null && catHint.isNotEmpty) {
      final newCat = Category()
        ..name = catHint.toTitleCase()
        ..icon = 'circle'
        ..colorValue = 0xFF6B7280
        ..type = parsed.type == 'income' ? 'income' : 'expense';
      await ref.read(categoryListProvider.notifier).add(newCat);
      categories = await ref.read(categoryListProvider.future);
      resolvedCategory =
          matchCategory(catHint, categories, type: parsed.type) ??
          categories
              .where((c) => c.name.toLowerCase() == catHint.toLowerCase())
              .firstOrNull;
    }

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
    final name =
        (parsed.categoryHint != null && parsed.categoryHint!.trim().isNotEmpty)
        ? parsed.categoryHint!.toTitleCase()
        : 'Quick Add';
    final txn = Transaction()
      ..name = name
      ..nameLower = name.toLowerCase()
      ..amount = parsed.amount!
      ..type = parsed.type
      ..categoryId = resolvedCategory.id.toString()
      ..accountId = resolvedAccountId
      ..importSource = 'quick_add'
      ..quickAddNote = input
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
    final l10n = context.l10n;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n.noAccountFoundTitle,
          style: localeFont(fontWeight: FontWeight.w700),
        ),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final hasError = _error != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        KuberHomeWidgetTitle(
          title: context.l10n.quickAddTitle,
          trailing: KuberSectionAction(
            label: sentenceCase('FULL SCREEN'),
            onTap: () => context.push('/quick-add'),
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
        // Board 3.2a: pill field (56, surfaceContainerHigh) with the mic
        // inside; send is a 56 circle that turns primary once there is text.
        Row(
          children: [
            Expanded(
              child: Container(
                height: 56,
                padding: const EdgeInsets.only(left: 20, right: 4),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: KuberShape.fullR,
                  border: hasError
                      ? Border.all(color: cs.error, width: 2)
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        enabled: !_isLoading,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: cs.onSurface,
                        ),
                        onTapOutside: (_) {
                          FocusManager.instance.primaryFocus?.unfocus();
                        },
                        decoration: InputDecoration(
                          hintText: context.l10n.quickAddHint,
                          hintStyle: theme.textTheme.bodyLarge!.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                          filled: false,
                          isCollapsed: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                        maxLines: 1,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          if (_controller.text.trim().isNotEmpty) _submit();
                        },
                      ),
                    ),
                    // Mic opens the full page with voice on.
                    AppIconButton(
                      icon: Icons.mic_none_rounded,
                      kind: AppIconButtonKind.plain,
                      semanticLabel: 'Voice',
                      onPressed: () => context.push('/quick-add?voice=1'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: KuberSpace.sm),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: _controller,
              builder: (context, value, child) {
                final isEmpty = value.text.trim().isEmpty;
                final isActive = !isEmpty || _isLoading;

                return GestureDetector(
                  onTap: (_isLoading || isEmpty) ? null : _submit,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: isActive ? cs.primary : cs.surfaceContainerHigh,
                      shape: BoxShape.circle,
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
                                  strokeWidth: 2.5,
                                  color: cs.onPrimary,
                                ),
                              )
                            : Icon(
                                key: const ValueKey('icon'),
                                Icons.send_rounded,
                                size: 22,
                                color: isActive
                                    ? cs.onPrimary
                                    : cs.onSurfaceVariant,
                              ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        if (hasError)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
            child: Text(
              _error!,
              style: theme.textTheme.bodySmall!.copyWith(color: cs.error),
            ),
          ),
      ],
    );
  }
}
