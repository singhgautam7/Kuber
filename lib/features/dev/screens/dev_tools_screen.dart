import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart' show sectionHeaderStyle;
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../pro/debug/billing_diagnostic_sheet.dart';
import '../../pro/debug/entitlement_override.dart';
import '../../pro/debug/entitlement_override_sheet.dart';
import '../../pro/services/billing_diagnostics.dart';
import '../providers/dev_mode_provider.dart';

class DevToolsScreen extends ConsumerWidget {
  const DevToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final tt = Theme.of(context).textTheme;
    final m = context.kuberMoney;
    Widget row(
      IconData icon,
      String label,
      String subtitle,
      VoidCallback onTap, {
      Widget trailing = const KuberChevron(),
    }) => KuberListRow(
      leading: KuberIconTile(icon: icon, tone: KuberTone.neutral),
      title: label,
      subtitle: subtitle,
      trailing: trailing,
      onTap: onTap,
    );
    Widget section(String title, List<Widget> rows, {bool danger = false}) =>
        Padding(
          padding: const EdgeInsets.only(top: KuberSpace.sectionGap - 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  bottom: KuberSpace.sectionHeaderGap,
                ),
                child: Text(
                  title,
                  style: danger
                      ? sectionHeaderStyle(context).copyWith(color: cs.error)
                      : sectionHeaderStyle(context),
                ),
              ),
              KuberGroup(children: rows),
            ],
          ),
        );

    return Scaffold(
      backgroundColor: cs.surface,
      body: KuberScrollAwayHeader(
        header: const KuberAppBar(showBack: true, title: 'Developer Tools'),
        body: ListView(
          padding: EdgeInsets.fromLTRB(
            KuberSpace.screenMargin,
            0,
            KuberSpace.screenMargin,
            KuberSpace.xl + MediaQuery.of(context).padding.bottom,
          ),
          children: [
            Container(
              padding: const EdgeInsets.all(KuberSpace.lg),
              decoration: BoxDecoration(
                color: m.warningContainer,
                borderRadius: KuberShape.largeR,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.construction_rounded,
                    size: 20,
                    color: m.onWarningContainer,
                  ),
                  const SizedBox(width: KuberSpace.md),
                  Expanded(
                    child: Text(
                      'These tools are for development and debugging only. '
                      'Not intended for regular use.',
                      style: tt.bodyMedium!.copyWith(
                        color: m.onWarningContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            section('TROUBLESHOOT', [
              row(
                Icons.build_outlined,
                'Troubleshoot',
                'Fix data and suggestion issues',
                () => context.push('/more/troubleshoot'),
              ),
              row(
                Icons.receipt_long_outlined,
                'Copy Billing Diagnostics',
                'Copy recent Play Billing logs and device metadata',
                () async {
                  final report = await BillingDiagnostics.instance
                      .generateDiagnosticsReport();
                  await Clipboard.setData(ClipboardData(text: report));
                  if (context.mounted) {
                    showKuberSnackBar(
                      context,
                      'Billing diagnostics copied to clipboard',
                    );
                  }
                },
                trailing: Icon(
                  Icons.copy_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ]),
            section('DATABASE', [
              row(
                Icons.storage_outlined,
                'DB Explorer',
                'Browse Isar collections (read-only)',
                () => context.push('/more/dev-tools/db-explorer'),
              ),
            ]),
            // QA/debug only: force entitlement states to exercise the Pro gates
            // without a real Play Billing purchase. Const false in Play builds,
            // so this block is tree-shaken out there.
            if (kEntitlementOverrideEnabled)
              section('ENTITLEMENT (QA)', [
                row(
                  Icons.workspace_premium_outlined,
                  'Entitlement Override',
                  'Force Free / Trial / Monthly / Yearly / Lifetime',
                  () => showEntitlementOverrideSheet(context),
                ),
                row(
                  Icons.fact_check_outlined,
                  'Billing Diagnostic',
                  'Read-only queryPurchases() vs resolver',
                  () => showBillingDiagnosticSheet(context),
                ),
              ]),
            section('DANGER ZONE', [
              KuberListRow(
                leading: const KuberIconTile(
                  icon: Icons.developer_mode_outlined,
                  tone: KuberTone.error,
                ),
                title: 'Disable Dev Tools',
                subtitle: 'Hide developer tools from the app',
                destructive: true,
                onTap: () => _showDisableConfirmation(context, ref),
              ),
            ], danger: true),
          ],
        ),
      ),
    );
  }

  Future<void> _showDisableConfirmation(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final cs = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Disable Dev Tools?'),
        content: const Text(
          'You can re-enable by tapping the version number 7 times.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: const Text('Disable'),
          ),
        ],
      ),
    );

    if (result == true && context.mounted) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('kuber_dev_mode', false);
      ref.invalidate(devModeProvider);

      if (context.mounted) {
        context.pop();
        showKuberSnackBar(context, 'Dev Tools disabled');
      }
    }
  }
}
