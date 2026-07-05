import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../settings/providers/settings_provider.dart';

const _configChannel = MethodChannel('com.grs.kuber/widget_config');

/// Flutter configuration screen for the Account Balance widget. Rendered inside
/// [AccountBalanceConfigActivity]; on Confirm it hands the selected account id
/// back to the native side which finishes the placement.
class AccountWidgetConfigScreen extends ConsumerStatefulWidget {
  final int widgetId;
  const AccountWidgetConfigScreen({super.key, required this.widgetId});

  @override
  ConsumerState<AccountWidgetConfigScreen> createState() => _AccountWidgetConfigScreenState();
}

class _AccountWidgetConfigScreenState extends ConsumerState<AccountWidgetConfigScreen> {
  int? _selectedId;

  Future<void> _confirm() async {
    if (_selectedId == null) return;
    await _configChannel.invokeMethod('confirm', {'value': _selectedId.toString()});
  }

  Future<void> _cancel() async {
    await _configChannel.invokeMethod('cancel');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final accountsAsync = ref.watch(allAccountsProvider);
    final balances = ref.watch(accountBalancesProvider).valueOrNull ?? const {};
    final fmt = ref.watch(formatterProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              KuberAppBar(
                title: 'Configure Account Widget',
                showBack: true,
                showBrand: false,
                onBack: _cancel,
              ),
              Expanded(
                child: accountsAsync.when(
                  loading: () => const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Could not load accounts', style: TextStyle(color: cs.error))),
                  data: (accounts) {
                    final enabled = accounts.where((a) => !a.isDisabled).toList();
                    return ListView(
                      padding: const EdgeInsets.fromLTRB(KuberSpacing.lg, KuberSpacing.sm, KuberSpacing.lg, KuberSpacing.lg),
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2, vertical: KuberSpacing.sm),
                          child: Text(
                            'Pick which account this widget shows on your home screen. You can add this widget again for other accounts.',
                            style: TextStyle(fontSize: 12.5, height: 1.5, color: cs.onSurfaceVariant),
                          ),
                        ),
                        for (final a in enabled)
                          _accountRow(context, a, (balances[a.id] ?? 0).toDouble(), fmt),
                      ],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(KuberSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    onPressed: _selectedId == null ? null : _confirm,
                    child: const Text('Confirm'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _accountRow(BuildContext context, Account a, double balance, AppFormatter fmt) {
    final cs = Theme.of(context).colorScheme;
    final selected = _selectedId == a.id;
    final isNegative = balance < 0;
    final amountColor = isNegative ? cs.error : cs.tertiary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        onTap: () => setState(() => _selectedId = a.id),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: selected ? cs.primary.withValues(alpha: 0.08) : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.lg),
            border: Border.all(color: selected ? cs.primary : cs.outlineVariant, width: selected ? 1.5 : 1),
          ),
          child: Row(
            children: [
              Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: selected ? cs.primary.withValues(alpha: 0.14) : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(a.isCreditCard ? Icons.credit_card : Icons.account_balance_outlined, size: 20, color: cs.onSurfaceVariant),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(a.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: cs.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 2),
                    Text(a.isCreditCard ? 'Credit card' : 'Account', style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text('${isNegative ? '−' : ''}${fmt.formatCurrency(balance.abs())}',
                  style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700, color: amountColor)),
              if (selected) ...[
                const SizedBox(width: 8),
                Icon(Icons.check_circle, size: 20, color: cs.primary),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
