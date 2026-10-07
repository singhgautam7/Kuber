import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/data_provider.dart';
import '../../settings/widgets/data_action_widgets.dart';
import '../../sms_import/providers/sms_import_provider.dart';

class TroubleshootScreen extends ConsumerWidget {
  const TroubleshootScreen({super.key});

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
              SliverToBoxAdapter(
                child: KuberAppBar(
                  showBack: true,
                  title: context.l10n.troubleshootTitle,
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpace.screenMargin,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    KuberGroup(
                      children: [
                        DataActionRow(
                          icon: Icons.manage_search_rounded,
                          title: context.l10n.rebuildSuggestions,
                          description: context.l10n.rebuildSuggestionsDesc,
                          onPressed: () => _confirmRebuild(context, ref),
                        ),
                        DataActionRow(
                          icon: Icons.delete_outline_rounded,
                          title: 'Reset SMS Imports',
                          description:
                              'Clears all currently tracked SMS records and runs a full re-scan of the SMS inbox.',
                          destructive: true,
                          onPressed: () => _confirmResetSms(context, ref),
                        ),
                      ],
                    ),
                    const SizedBox(height: KuberSpace.xxl),
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

  void _confirmRebuild(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmActionSheet(
        icon: Icons.manage_search_rounded,
        title: '${context.l10n.rebuildSuggestions}?',
        description: context.l10n.rebuildSuggestionsDesc,
        confirmLabel: context.l10n.rebuildSuggestions,
        onConfirm: () =>
            ref.read(dataControllerProvider.notifier).rebuildSuggestions(),
      ),
    );
  }

  void _confirmResetSms(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmActionSheet(
        icon: Icons.delete_outline_rounded,
        title: 'Reset SMS imports?',
        description:
            'This will clear all the SMS imports we have right now and re-read all the SMS again with the parser. Are you sure you want to proceed?',
        confirmLabel: 'Reset',
        destructive: true,
        onConfirm: () => ref.read(smsImportProvider.notifier).resetSmsImports(),
      ),
    );
  }
}
