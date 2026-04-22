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
                      icon: Icons.science_outlined,
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
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ConfirmActionSheet(
        icon: Icons.delete_forever_rounded,
        title: 'Clear All Data?',
        description:
            'This will permanently delete all your transactions, accounts, categories, and recurring rules. This action cannot be undone.',
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
      builder: (_) => _ConfirmActionSheet(
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

// ---------------------------------------------------------------------------
// Confirmation bottom sheet
// ---------------------------------------------------------------------------

class _ConfirmActionSheet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String confirmLabel;
  final bool destructive;
  final bool warnDescription;
  final VoidCallback onConfirm;

  const _ConfirmActionSheet({
    required this.icon,
    required this.title,
    required this.description,
    required this.confirmLabel,
    required this.onConfirm,
    this.destructive = false,
    this.warnDescription = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final viewPadding = MediaQuery.of(context).viewPadding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(
        KuberSpacing.xl,
        KuberSpacing.lg,
        KuberSpacing.xl,
        viewPadding > 0 ? viewPadding + KuberSpacing.lg : KuberSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: cs.onSurfaceVariant.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: KuberSpacing.xl),

          // Icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: destructive
                  ? cs.error.withValues(alpha: 0.1)
                  : cs.primaryContainer.withValues(alpha: 0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 28,
              color: destructive ? cs.error : cs.primary,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),

          // Title
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              letterSpacing: -0.3,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: KuberSpacing.sm),

          // Description
          if (warnDescription)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(KuberSpacing.lg),
              decoration: BoxDecoration(
                color: cs.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 18, color: cs.error),
                  const SizedBox(width: KuberSpacing.md),
                  Expanded(
                    child: Text(
                      description,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: cs.error,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            )
          else
            Text(
              description,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: cs.onSurfaceVariant,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: KuberSpacing.xl),

          // Confirm button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                onConfirm();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: destructive ? cs.error : cs.primary,
                foregroundColor: destructive ? cs.onError : cs.onPrimary,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
              ),
              child: Text(
                confirmLabel,
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: KuberSpacing.md),

          // Cancel button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: cs.surfaceContainerHigh,
                foregroundColor: cs.onSurface,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  side: BorderSide(color: cs.outline.withValues(alpha: 0.1)),
                ),
              ),
              child: Text(
                'Cancel',
                style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
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
