import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/data_provider.dart';
import '../../settings/widgets/data_action_widgets.dart';

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
              const SliverToBoxAdapter(
                child: KuberAppBar(showBack: true, title: 'Troubleshoot'),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Trouble\nshoot',
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
                        'Fix data issues and repair app state.',
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
                      icon: Icons.manage_search_rounded,
                      title: 'Suggestions not working?',
                      description:
                          'Clears and rebuilds the autocomplete suggestion index from your existing transactions. Your transaction data will not be affected.',
                      onPressed: () => _confirmRebuild(context, ref),
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

  void _confirmRebuild(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmActionSheet(
        icon: Icons.manage_search_rounded,
        title: 'Rebuild Suggestions?',
        description:
            'This will clear all saved suggestions and rebuild them from your transactions. Your transaction data will not be affected.',
        confirmLabel: 'Rebuild',
        onConfirm: () => ref.read(dataControllerProvider.notifier).rebuildSuggestions(),
      ),
    );
  }
}
