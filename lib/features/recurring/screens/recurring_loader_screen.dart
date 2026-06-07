import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import '../../../core/theme/app_text_styles.dart';


import '../../../core/theme/app_theme.dart';
import '../../../main.dart';
import '../../../shared/widgets/loading_widgets.dart';
import '../../backups/providers/backup_provider.dart';
import '../../budgets/services/budget_service.dart';
enum _LoaderPhase { recurring, backup }

class RecurringLoaderScreen extends ConsumerStatefulWidget {
  const RecurringLoaderScreen({super.key});

  @override
  ConsumerState<RecurringLoaderScreen> createState() =>
      _RecurringLoaderScreenState();
}

class _RecurringLoaderScreenState extends ConsumerState<RecurringLoaderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeIn;
  bool _navigating = false;
  late _LoaderPhase _phase;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeIn = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _phase = ref.read(recurringProcessResultProvider) > 0
        ? _LoaderPhase.recurring
        : _LoaderPhase.backup;

    _controller.forward();

    // Initialize budgets
    ref.read(budgetServiceProvider).init();

    Future.delayed(const Duration(milliseconds: 2000), () async {
      final backupDue = ref.read(automaticBackupDueProvider);
      if (mounted && backupDue) {
        setState(() => _phase = _LoaderPhase.backup);
        await ref.read(backupSettingsProvider.notifier).runDueBackup();
        await Future.delayed(const Duration(milliseconds: 1400));
      }
      if (mounted && !_navigating) {
        _navigating = true;
        // Reset the state so the router doesn't redirect us back here
        ref.read(recurringProcessResultProvider.notifier).state = 0;

        ref.read(automaticBackupDueProvider.notifier).state = false;
        context.go('/');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final count = ref.watch(recurringProcessResultProvider);
    final textTheme = Theme.of(context).textTheme;
    final title = switch (_phase) {
      _LoaderPhase.backup => context.l10n.backingUpAuto,
      _LoaderPhase.recurring => context.l10n.processingRecurring,
    };
    final subtitle = switch (_phase) {
      _LoaderPhase.backup => context.l10n.savingCopyToFolder,
      _LoaderPhase.recurring => context.l10n.creatingMissedTxns,
    };
    final statusLabel = switch (_phase) {
      _LoaderPhase.backup => context.l10n.folderUpper,
      _LoaderPhase.recurring => context.l10n.processedUpper,
    };
    final statusValue = switch (_phase) {
      _LoaderPhase.backup => context.l10n.selectedLabel,
      _LoaderPhase.recurring => context.l10n.nTransactions(count),
    };

    return Scaffold(
      backgroundColor: cs.surface,
      body: Center(
        child: FadeTransition(
          opacity: _fadeIn,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SweepRingWidget(controller: _controller),
              const SizedBox(height: KuberSpacing.xl),

              Text(
                title,
                style: AppTextStyles.inter.copyWith(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              Text(
                subtitle,
                style: textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: KuberSpacing.xl),

              // Status pills
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StatusPill(label: context.l10n.networkUpper, value: context.l10n.localOnly),
                  const SizedBox(width: KuberSpacing.md),
                  StatusPill(label: statusLabel, value: statusValue),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
