import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../providers/data_provider.dart';
import '../widgets/data_action_widgets.dart';
import '../widgets/data_export_bottom_sheet.dart';
import '../widgets/data_import_bottom_sheet.dart';

class DataManagementScreen extends ConsumerWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(dataControllerProvider);

    ref.listen(dataControllerProvider, (previous, next) {
      if (next.status == DataOpStatus.success && next.message != null) {
        showKuberSnackBar(context, next.message!);
        ref.read(dataControllerProvider.notifier).reset();
      } else if (next.status == DataOpStatus.error && next.message != null) {
        showKuberSnackBar(context, next.message!, isError: true);
        ref.read(dataControllerProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: KuberAppBar(showBack: true, title: 'Data'),
              ),
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
                        'Import, export, and manage your local data.',
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
                    DataActionRow(
                      icon: Icons.upload_file_rounded,
                      title: 'Export',
                      description:
                          'Download your data as a CSV spreadsheet or a full JSON backup.',
                      onPressed: () => showDataExportBottomSheet(context),
                    ),
                    const SizedBox(height: KuberSpacing.md),
                    DataActionRow(
                      icon: Icons.download_rounded,
                      title: 'Import',
                      description:
                          'Restore data from a CSV file or a JSON backup.',
                      onPressed: () => showDataImportBottomSheet(context),
                    ),
                    const SizedBox(height: KuberSpacing.md),
                    DataActionRow(
                      icon: Icons.science_outlined,
                      title: 'Generate Mock Data',
                      description:
                          'Populate the app with realistic sample data for testing.',
                      onPressed: () => _confirmMockData(context, ref),
                    ),
                    const SizedBox(height: KuberSpacing.md),
                    DataActionRow(
                      icon: Icons.delete_forever_rounded,
                      title: 'Clear All Data',
                      description:
                          'Permanently delete all stored data and reset the app.',
                      destructive: true,
                      onPressed: () => _confirmClearData(context, ref),
                    ),
                    const SizedBox(height: KuberSpacing.xxl),
                  ]),
                ),
              ),
            ],
          ),
          if (state.status == DataOpStatus.loading)
            DataLoadingOverlay(message: state.loadingMessage ?? 'Processing…'),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmActionSheet(
        icon: Icons.delete_forever_rounded,
        title: 'Clear All Data?',
        description:
            'This will permanently delete ALL data — transactions, accounts, categories, tags, budgets, recurring rules, and suggestions. This action cannot be undone.',
        confirmLabel: 'Clear All Data',
        destructive: true,
        onConfirm: () => ref.read(dataControllerProvider.notifier).clearAllData(),
      ),
    );
  }

  void _confirmMockData(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmActionSheet(
        icon: Icons.science_outlined,
        title: 'Generate Mock Data?',
        description:
            'All existing data will be permanently deleted and replaced with sample data.',
        confirmLabel: 'Generate',
        warnDescription: true,
        onConfirm: () => ref.read(dataControllerProvider.notifier).generateMockData(),
      ),
    );
  }
}

