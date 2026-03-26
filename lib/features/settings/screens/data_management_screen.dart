import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../providers/data_provider.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import 'package:share_plus/share_plus.dart';
import '../../../shared/widgets/loading_widgets.dart';
import 'package:open_filex/open_filex.dart';

class DataManagementScreen extends ConsumerWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(dataControllerProvider);

    // Listen for state changes to show snackbars
    ref.listen(dataControllerProvider, (previous, next) {
      if (next.status == DataOpStatus.success && next.message != null) {
        String msg = next.message!;

        final filePath = next.filePath;
        showKuberSnackBar(
          context,
          msg,
          actionLabel: filePath != null ? 'OPEN' : null,
          onAction: filePath != null ? () => OpenFilex.open(filePath) : null,
          secondaryActionLabel: filePath != null ? 'SHARE' : null,
          onSecondaryAction: (next.filePaths != null && next.filePaths!.isNotEmpty)
              ? () => SharePlus.instance.share(
                  ShareParams(files: next.filePaths!.map((p) => XFile(p)).toList()))
              : (filePath != null
                  ? () => SharePlus.instance.share(ShareParams(files: [XFile(filePath)]))
                  : null),
        );
        ref.read(dataControllerProvider.notifier).reset();
      } else if (next.status == DataOpStatus.error && next.message != null) {
        showKuberSnackBar(
          context,
          next.message!,
          isError: true,
        );
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
                    _DataCard(
                      icon: Icons.upload_file_rounded,
                      title: 'Export All Data',
                      description: 'Download all your financial data as a CSV file.',
                      buttonLabel: 'Export Data',
                      onPressed: () => ref.read(dataControllerProvider.notifier).exportData(),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    _DataCard(
                      icon: Icons.download_rounded,
                      title: 'Import Data',
                      description: 'Upload transactions using a CSV file. Use our template for best results.',
                      buttonLabel: 'Import CSV',
                      secondaryButtonLabel: 'Download Template',
                      onPressed: () => ref.read(dataControllerProvider.notifier).importData(),
                      onSecondaryPressed: () => ref.read(dataControllerProvider.notifier).downloadTemplate(),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    _DataCard(
                      icon: Icons.auto_awesome_rounded,
                      title: 'Generate Mock Data',
                      description: 'Populate app with realistic sample data for testing. This will clear existing data.',
                      buttonLabel: 'Generate',
                      onPressed: () => _confirmMockData(context, ref),
                    ),
                    const SizedBox(height: KuberSpacing.lg),
                    _DataCard(
                      icon: Icons.delete_forever_rounded,
                      title: 'Clear All Data',
                      description: 'Permanently delete all stored data and reset the app.',
                      buttonLabel: 'Clear All Data',
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
            _DataLoadingOverlay(message: state.loadingMessage ?? 'Processing...'),
        ],
      ),
    );
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Data?'),
        content: const Text('This will permanently delete all your transactions, accounts, categories, and recurring rules. This action cannot be undone.'),
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
        content: const Text('This will delete all existing data and replace it with sample data. Are you sure?'),
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

class _DataLoadingOverlay extends StatefulWidget {
  final String message;
  const _DataLoadingOverlay({required this.message});

  @override
  State<_DataLoadingOverlay> createState() => _DataLoadingOverlayState();
}

class _DataLoadingOverlayState extends State<_DataLoadingOverlay> with SingleTickerProviderStateMixin {
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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
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

class _DataCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final String? secondaryButtonLabel;
  final VoidCallback onPressed;
  final VoidCallback? onSecondaryPressed;
  final bool destructive;

  const _DataCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    this.secondaryButtonLabel,
    required this.onPressed,
    this.onSecondaryPressed,
    this.destructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(KuberSpacing.sm),
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                child: Icon(icon, color: cs.onSurfaceVariant, size: 20),
              ),
              const SizedBox(width: KuberSpacing.md),
              Text(
                title,
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.md),
          Text(
            description,
            style: textTheme.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: KuberSpacing.lg),
          Row(
            children: [
              if (secondaryButtonLabel != null) ...[
                Expanded(
                  child: OutlinedButton(
                    onPressed: onSecondaryPressed,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text(secondaryButtonLabel!),
                  ),
                ),
                const SizedBox(width: KuberSpacing.sm),
              ],
              Expanded(
                child: FilledButton(
                  onPressed: onPressed,
                  style: FilledButton.styleFrom(
                    backgroundColor: destructive ? cs.error : cs.primary,
                    foregroundColor: destructive ? cs.onError : cs.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text(buttonLabel),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
