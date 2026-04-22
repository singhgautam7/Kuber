import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/loading_widgets.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../providers/data_provider.dart';
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
                    _DataRow(
                      icon: Icons.upload_file_rounded,
                      title: 'Export',
                      description:
                          'Download your data as a CSV spreadsheet or a full JSON backup.',
                      onPressed: () => showDataExportBottomSheet(context),
                    ),
                    const SizedBox(height: KuberSpacing.md),
                    _DataRow(
                      icon: Icons.download_rounded,
                      title: 'Import',
                      description:
                          'Restore data from a CSV file or a JSON backup.',
                      onPressed: () => showDataImportBottomSheet(context),
                    ),
                    const SizedBox(height: KuberSpacing.md),
                    _DataRow(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Generate Mock Data',
                      description:
                          'Populate the app with realistic sample data for testing.',
                      onPressed: () => _confirmMockData(context, ref),
                    ),
                    const SizedBox(height: KuberSpacing.md),
                    _DataRow(
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
            _DataLoadingOverlay(message: state.loadingMessage ?? 'Processing…'),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text(
            'This will permanently delete all your transactions, accounts, categories, and recurring rules. This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(dataControllerProvider.notifier).clearAllData();
            },
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );
  }

  void _confirmMockData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Generate Mock Data?'),
        content: const Text(
            'This will delete all existing data and replace it with sample data. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(dataControllerProvider.notifier).generateMockData();
            },
            child: const Text('Generate'),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Row widget
// ---------------------------------------------------------------------------

class _DataRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onPressed;
  final bool destructive;

  const _DataRow({
    required this.icon,
    required this.title,
    required this.description,
    required this.onPressed,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final iconBg = destructive
        ? cs.errorContainer.withValues(alpha: 0.5)
        : cs.surfaceContainerHigh;
    final iconColor = destructive ? cs.error : cs.onSurfaceVariant;
    final borderColor = destructive
        ? cs.error.withValues(alpha: 0.2)
        : cs.outline.withValues(alpha: 0.4);

    return Material(
      color: cs.surfaceContainer,
      borderRadius: BorderRadius.circular(KuberRadius.lg),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        child: Container(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(KuberRadius.lg),
            border: Border.all(color: borderColor),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KuberSpacing.sm),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: destructive ? cs.error : cs.onSurface,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: destructive
                    ? cs.error.withValues(alpha: 0.7)
                    : cs.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Loading overlay (unchanged)
// ---------------------------------------------------------------------------

class _DataLoadingOverlay extends StatefulWidget {
  final String message;
  const _DataLoadingOverlay({required this.message});

  @override
  State<_DataLoadingOverlay> createState() => _DataLoadingOverlayState();
}

class _DataLoadingOverlayState extends State<_DataLoadingOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      color: Colors.black54,
      width: double.infinity,
      height: double.infinity,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(KuberRadius.lg),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SweepRingWidget(controller: _controller),
              const SizedBox(height: KuberSpacing.lg),
              Text(
                widget.message,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
