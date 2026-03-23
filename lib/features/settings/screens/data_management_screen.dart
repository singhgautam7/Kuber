import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../providers/settings_provider.dart';
import '../../../main.dart';

class DataManagementScreen extends ConsumerWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: const KuberAppBar(showBack: true, title: 'Data'),
      body: CustomScrollView(
        slivers: [
          // Page header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Data\nManagement',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Control your local data and backups.',
                    style: GoogleFonts.inter(
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
                _DataSection(
                  children: [
                    _DataTile(
                      icon: Icons.upload_file_rounded,
                      label: 'Export Data',
                      onTap: () {
                        // Stub — no-op
                      },
                    ),
                    Divider(height: 1, color: cs.outline),
                    _DataTile(
                      icon: Icons.delete_forever_rounded,
                      label: 'Clear All Data',
                      destructive: true,
                      onTap: () => _confirmClearData(context, ref),
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

  void _confirmClearData(BuildContext context, WidgetRef ref) {
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

                if (context.mounted) {
                  RestartWidget.restartApp(context);
                }
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

class _DataSection extends StatelessWidget {
  final List<Widget> children;
  const _DataSection({required this.children});

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

class _DataTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool destructive;

  const _DataTile({
    required this.icon,
    required this.label,
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
            const Spacer(),
            Icon(Icons.chevron_right_rounded,
                color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }
}
