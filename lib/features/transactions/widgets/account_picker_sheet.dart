import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/account_helpers.dart';
import '../../../core/utils/color_harmonizer.dart';
import '../../../shared/widgets/add_new_button.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../accounts/providers/account_provider.dart';
import '../../accounts/widgets/account_form.dart';
import '../../settings/providers/settings_provider.dart'
    show currencyProvider, formatterProvider;

class AccountPickerSheet extends ConsumerStatefulWidget {
  final int? selectedAccountId;
  final ValueChanged<int> onSelected;
  final int? excludeAccountId;

  const AccountPickerSheet({
    super.key,
    required this.selectedAccountId,
    required this.onSelected,
    this.excludeAccountId,
  });

  @override
  ConsumerState<AccountPickerSheet> createState() => _AccountPickerSheetState();
}

class _AccountPickerSheetState extends ConsumerState<AccountPickerSheet> {
  final _searchController = TextEditingController();
  // Search query is reset on every open because the controller (and this state)
  // is created fresh each time the sheet is shown.
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;
    final accounts = ref.watch(accountListProvider);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            KuberSpace.screenMargin,
            KuberSpace.sm,
            KuberSpace.sm,
            0,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: KuberShape.fullR,
                  ),
                ),
              ),
              const SizedBox(height: KuberSpace.lg),

              // Title + subtitle
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.l10n.selectAccountTitle,
                          style: textTheme.titleLarge?.copyWith(
                            color: cs.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          context.l10n.chooseAccountSubtitle,
                          style: textTheme.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AppIconButton(
                    icon: Icons.close_rounded,
                    semanticLabel: MaterialLocalizations.of(
                      context,
                    ).closeButtonTooltip,
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: KuberSpace.md),

              // Search field. Not autofocused (matches the category picker) so
              // the keyboard doesn't pop up with the sheet. List is small, so
              // no debounce is needed once the user does type.
              Padding(
                padding: const EdgeInsets.only(right: KuberSpace.md),
                child: TextField(
                  controller: _searchController,
                  autofocus: false,
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  style: textTheme.bodyMedium?.copyWith(color: cs.onSurface),
                  decoration: InputDecoration(
                    hintText: context.l10n.searchAccountsHint,
                    hintStyle: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                    prefixIcon: Icon(Icons.search, color: cs.onSurfaceVariant),
                    filled: true,
                    fillColor: cs.surfaceContainerHigh,
                    contentPadding: const EdgeInsets.symmetric(vertical: 14),
                    border: const OutlineInputBorder(
                      borderRadius: KuberShape.fullR,
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderRadius: KuberShape.fullR,
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: KuberShape.fullR,
                      borderSide: BorderSide(color: cs.primary, width: 2),
                    ),
                  ),
                  onChanged: (v) =>
                      setState(() => _query = v.trim().toLowerCase()),
                ),
              ),
              const SizedBox(height: KuberSpace.lg),
            ],
          ),
        ),

        // Account list
        Flexible(
          child: accounts.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) =>
                Center(child: Text('${context.l10n.errorLabel}: $e')),
            data: (allAccs) {
              var accs = widget.excludeAccountId != null
                  ? allAccs
                        .where((a) => a.id != widget.excludeAccountId)
                        .toList()
                  : allAccs;
              if (accs.isEmpty) {
                return Center(
                  child: Text(
                    context.l10n.noAccountsYet,
                    style: textTheme.bodyMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                );
              }

              if (_query.isNotEmpty) {
                accs = accs
                    .where((a) => a.name.toLowerCase().contains(_query))
                    .toList();
              }

              if (accs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(KuberSpace.lg),
                    child: Text(
                      context.l10n.noAccountsMatch(_searchController.text),
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                );
              }

              return ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpace.screenMargin,
                ),
                children: [
                  KuberGroup(
                    children: [
                      for (final acc in accs)
                        () {
                          final selected = acc.id == widget.selectedAccountId;
                          final color = resolveAccountColor(acc);

                          return _AccountTile(
                            name: acc.name,
                            type: (acc.isCreditCard
                                ? context.l10n.creditCardLabel
                                : switch (acc.type.toLowerCase()) {
                                    'bank' => context.l10n.bankLabel,
                                    'wallet' => context.l10n.walletLabel,
                                    'cash' => context.l10n.cashLabel,
                                    _ => acc.type,
                                  }),
                            icon: resolveAccountIcon(acc),
                            color: color,
                            selected: selected,
                            balance: ref.watch(accountBalanceProvider(acc.id)),
                            isCreditCard: acc.isCreditCard,
                            creditLimit: acc.creditLimit,
                            currencySymbol: ref.watch(currencyProvider).symbol,
                            onTap: () => widget.onSelected(acc.id),
                          );
                        }(),
                    ],
                  ),
                ],
              );
            },
          ),
        ),

        // Add new account button
        AddNewButton(
          label: context.l10n.addNewAccount,
          onTap: () {
            Navigator.pop(context); // Close picker
            showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (context) => Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerLow,
                  borderRadius: KuberShape.sheetR,
                ),
                padding: EdgeInsets.fromLTRB(
                  KuberSpace.lg,
                  KuberSpace.lg,
                  KuberSpace.lg,
                  MediaQuery.of(context).viewInsets.bottom + KuberSpace.xl,
                ),
                child: const SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [AccountForm()],
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _AccountTile extends ConsumerWidget {
  final String name;
  final String type;
  final IconData icon;
  final Color color;
  final bool selected;
  final AsyncValue<double> balance;
  final bool isCreditCard;
  final double? creditLimit;
  final String currencySymbol;
  final VoidCallback onTap;

  const _AccountTile({
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.selected,
    required this.balance,
    this.isCreditCard = false,
    this.creditLimit,
    required this.currencySymbol,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final textTheme = theme.textTheme;

    final tones = categoryTones(context, color);
    return Material(
      color: selected ? cs.secondaryContainer : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 72),
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpace.lg,
            vertical: KuberSpace.sm,
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: tones.container,
                  borderRadius: KuberShape.mediumR,
                ),
                child: Icon(icon, size: 20, color: tones.fg),
              ),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium?.copyWith(
                        color: selected
                            ? cs.onSecondaryContainer
                            : cs.onSurface,
                      ),
                    ),
                    Text(
                      type,
                      style: textTheme.bodyMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              balance.when(
                loading: () => SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (bal) {
                  final formatter = ref.watch(formatterProvider);
                  final isNegative = bal < 0;
                  final display = isCreditCard && creditLimit != null
                      ? '${formatter.formatCurrency(bal)} / ${formatter.formatCurrency(creditLimit!)}'
                      : formatter.formatCurrency(bal);
                  return Text(
                    display,
                    style: textTheme.titleSmall?.copyWith(
                      color: isNegative
                          ? context.kuberMoney.expense
                          : cs.onSurfaceVariant,
                    ),
                  );
                },
              ),
              if (selected) ...[
                const SizedBox(width: KuberSpace.sm),
                Icon(Icons.check_rounded, size: 20, color: cs.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
