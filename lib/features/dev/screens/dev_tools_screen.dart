import 'package:flutter/services.dart' show Clipboard, ClipboardData;
import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../pro/debug/entitlement_override_sheet.dart';
import '../../pro/services/billing_diagnostics.dart';
import '../../settings/widgets/settings_widgets.dart'; // for SquircleIcon
import '../providers/dev_mode_provider.dart';

class DevToolsScreen extends ConsumerWidget {
  const DevToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(showBack: true, showHome: true, title: ''),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Developer\nTools',
                    style: localeFont(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'These tools are for development and debugging only. Not intended for regular use.',
                    style: localeFont(
                      fontSize: 13,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _SectionLabel(label: 'TROUBLESHOOT'),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.build_outlined,
                      label: 'Troubleshoot',
                      subtitle: 'Fix data and suggestion issues',
                      onTap: () => context.push('/more/troubleshoot'),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'Copy Billing Diagnostics',
                      subtitle: 'Copy recent Play Billing logs and device metadata',
                      onTap: () async {
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
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),
                _SectionLabel(label: 'DATABASE'),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.storage_outlined,
                      label: 'DB Explorer',
                      subtitle: 'Browse Isar collections (read-only)',
                      onTap: () => context.push('/more/dev-tools/db-explorer'),
                      trailing: Icon(
                        Icons.chevron_right_rounded,
                        color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                        size: 20,
                      ),
                    ),
                  ],
                ),
                // DEBUG-ONLY: force entitlement states to exercise the Pro
                // gates without a real Play Billing purchase. kDebugMode is a
                // const false in release, so this whole block is tree-shaken out.
                if (kDebugMode) ...[
                  const SizedBox(height: KuberSpacing.xl),
                  _SectionLabel(label: 'ENTITLEMENT (DEBUG)'),
                  const SizedBox(height: KuberSpacing.sm),
                  _SettingsCard(
                    children: [
                      _SettingsTile(
                        icon: Icons.workspace_premium_outlined,
                        label: 'Entitlement Override',
                        subtitle: 'Force Free / Trial / Monthly / Yearly / Lifetime',
                        onTap: () => showEntitlementOverrideSheet(context),
                        trailing: Icon(
                          Icons.chevron_right_rounded,
                          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: KuberSpacing.xl),
                _SectionLabel(label: 'DANGER ZONE'),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.developer_mode_outlined,
                      iconColor: cs.error,
                      label: 'Disable Dev Tools',
                      subtitle: 'Hide developer tools from the app',
                      onTap: () => _showDisableConfirmation(context, ref),
                    ),
                  ],
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDisableConfirmation(BuildContext context, WidgetRef ref) async {
    final cs = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(KuberRadius.lg)),
        title: Text(
          'Disable Dev Tools?',
          style: localeFont(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: cs.onSurface,
          ),
        ),
        content: Text(
          'You can re-enable by tapping the version number 7 times.',
          style: localeFont(
            fontSize: 15,
            color: cs.onSurfaceVariant,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'Cancel',
              style: localeFont(
                fontWeight: FontWeight.w600,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.error,
              foregroundColor: cs.onError,
            ),
            child: Text(
              'Disable',
              style: localeFont(fontWeight: FontWeight.w600),
            ),
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

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: KuberSpacing.xs),
      child: Text(
        label,
        style: localeFont(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color? iconColor;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    this.iconColor,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.md,
        ),
        child: Row(
          children: [
            SquircleIcon(icon: icon, size: 18, padding: 8, color: iconColor),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: localeFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: localeFont(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }
}