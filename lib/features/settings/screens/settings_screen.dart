import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../accounts/providers/account_provider.dart';
import '../../categories/providers/category_provider.dart';
import '../../recurring/providers/recurring_provider.dart';
import '../../transactions/providers/transaction_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _userNameController;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider).valueOrNull;
    _userNameController = TextEditingController(text: settings?.userName ?? '');
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider).valueOrNull;
    final currentTheme = settings?.themeMode ?? ThemeMode.system;
    final currency = ref.watch(currencyProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const KuberAppBar(showBack: true, title: 'Settings'),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.lg,
        ),
        children: [
          // APPEARANCE
          _SectionLabel(label: 'APPEARANCE'),
          const SizedBox(height: KuberSpacing.sm),
          _SettingsCard(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                  vertical: KuberSpacing.md,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.palette_outlined, size: 20, color: cs.onSurface),
                        const SizedBox(width: KuberSpacing.md),
                        Text(
                          'Theme',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: cs.onSurface,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                          ),
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                          ),
                        ],
                        selected: {currentTheme},
                        onSelectionChanged: (val) {
                          ref
                              .read(settingsProvider.notifier)
                              .setThemeMode(val.first);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: KuberSpacing.xl),

          // PREFERENCE
          _SectionLabel(label: 'PREFERENCE'),
          const SizedBox(height: KuberSpacing.sm),
          _SettingsCard(
            children: [
              // User Name
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                  vertical: KuberSpacing.md,
                ),
                child: Row(
                  children: [
                    Icon(Icons.person_outline_rounded, size: 20, color: cs.onSurface),
                    const SizedBox(width: KuberSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Your Name',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: cs.onSurface,
                            ),
                          ),
                          const SizedBox(height: KuberSpacing.xs),
                          TextField(
                            controller: _userNameController,
                            onChanged: (val) {
                              ref
                                  .read(settingsProvider.notifier)
                                  .setUserName(val.trim());
                            },
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: cs.onSurfaceVariant,
                            ),
                            decoration: InputDecoration(
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                              hintText: 'Enter your name',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 13,
                                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              border: InputBorder.none,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: cs.outline),
              _SettingsTile(
                icon: Icons.attach_money_rounded,
                label: 'Currency',
                trailing: GestureDetector(
                  onTap: () => _showCurrencyPicker(context),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${currency.symbol}  ${currency.code}',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: KuberSpacing.xs),
                      Icon(Icons.chevron_right_rounded,
                          color: cs.onSurfaceVariant, size: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: KuberSpacing.xl),

          // DATA
          _SectionLabel(label: 'DATA'),
          const SizedBox(height: KuberSpacing.sm),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.upload_file_rounded,
                label: 'Export Data',
                onTap: () {
                  // Stub — no-op
                },
              ),
              Divider(height: 1, color: cs.outline),
              _SettingsTile(
                icon: Icons.delete_forever_rounded,
                label: 'Clear All Data',
                destructive: true,
                onTap: () => _confirmClearData(context),
              ),
            ],
          ),

          const SizedBox(height: KuberSpacing.xl),

          // ABOUT
          _SectionLabel(label: 'ABOUT'),
          const SizedBox(height: KuberSpacing.sm),
          _SettingsCard(
            children: [
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                label: 'App Version',
                trailing: Text(
                  'v1.0.0',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final currentCode = ref.read(currencyProvider).code;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        side: BorderSide(color: cs.outline),
      ),
      builder: (ctx) {
        final sheetCs = Theme.of(ctx).colorScheme;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                const SizedBox(height: KuberSpacing.md),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sheetCs.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                Text(
                  'Select Currency',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: sheetCs.onSurface,
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: kCurrencies.length,
                    itemBuilder: (ctx, i) {
                      final c = kCurrencies[i];
                      final isSelected = c.code == currentCode;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? sheetCs.primaryContainer
                                : sheetCs.surfaceContainerHigh,
                            borderRadius:
                                BorderRadius.circular(KuberRadius.md),
                          ),
                          child: Text(
                            c.symbol,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? sheetCs.primary
                                  : sheetCs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        title: Text(
                          c.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: sheetCs.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          c.code,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: sheetCs.onSurfaceVariant,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded,
                                color: sheetCs.primary, size: 20)
                            : null,
                        onTap: () {
                          ref
                              .read(settingsProvider.notifier)
                              .setCurrency(c.code);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmClearData(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) {
        final dCs = Theme.of(ctx).colorScheme;
        return AlertDialog(
          title: Text(
            'Clear All Data?',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w700,
              color: dCs.onSurface,
            ),
          ),
          content: Text(
            'This will permanently delete all your transactions, accounts, categories, and recurring rules. This action cannot be undone.',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: dCs.onSurfaceVariant,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(ctx);
                final isar = ref.read(isarProvider);
                await isar.writeTxn(() => isar.clear());
                await ref.read(settingsProvider.notifier).clearAllData();
                ref.invalidate(transactionListProvider);
                ref.invalidate(accountListProvider);
                ref.invalidate(categoryListProvider);
                ref.invalidate(recurringListProvider);
              },
              style: FilledButton.styleFrom(
                backgroundColor: cs.error,
              ),
              child: const Text('Clear All Data'),
            ),
          ],
        );
      },
    );
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
        style: GoogleFonts.inter(
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
  final String label;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool destructive;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
    this.onTap,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = destructive ? cs.error : cs.onSurface;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: KuberSpacing.md),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            if (trailing != null) Flexible(child: trailing!),
          ],
        ),
      ),
    );
  }
}
