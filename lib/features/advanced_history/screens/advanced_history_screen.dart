import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_menu.dart';
import '../../pro/paywall/pro_state.dart';
import '../providers/ah_providers.dart';
import '../widgets/charts/ah_charts_area.dart';
import '../widgets/common/ah_common.dart';
import '../widgets/common/ah_motion.dart';
import '../widgets/dashboard/ah_action_row.dart';
import '../widgets/dashboard/ah_export_sheet.dart';
import '../widgets/dashboard/ah_kpi_row.dart';
import '../widgets/dashboard/ah_results.dart';
import '../widgets/dashboard/ah_start_screen.dart';
import '../widgets/help/ah_help_sheet.dart';
import '../widgets/saved/ah_change_bar.dart';
import '../widgets/saved/ah_save_sheet.dart';
import '../widgets/saved/ah_saved_sheet.dart';

/// Advanced History. Free users only ever see the Pro gate page and no query
/// provider is watched for them.
class AdvancedHistoryScreen extends ConsumerWidget {
  const AdvancedHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAccess =
        ref.watch(kuberProStateProvider.select((s) => s.hasProAccess));
    return hasAccess ? const AhPage() : const AhGatePage();
  }
}

/// AH.1: the Pro gate page.
class AhGatePage extends StatelessWidget {
  const AhGatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final benefits = [l.ahdGateB1, l.ahdGateB2, l.ahdGateB3, l.ahdGateB4];

    Widget sampleRow(String name, double share) => Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Row(children: [
                Expanded(
                    child: Text(name,
                        style: tt.bodyMedium!.copyWith(color: cs.onSurface))),
                Text('${(share * 100).round()}%',
                    style: tt.bodySmall!
                        .copyWith(color: cs.onSurfaceVariant)),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: KuberShape.fullR,
                child: LinearProgressIndicator(
                  value: share,
                  minHeight: 4,
                  color: cs.primary,
                  backgroundColor: cs.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        );

    return Scaffold(
      appBar: KuberAppBar(title: l.ahdTitle, showBack: true),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin, KuberSpace.sm,
            KuberSpace.screenMargin, KuberSpace.xxl),
        children: [
          ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.all(KuberSpace.lg),
              decoration: BoxDecoration(
                color: cs.surfaceContainer,
                borderRadius: KuberShape.cardR,
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        decoration: BoxDecoration(
                            color: cs.secondaryContainer,
                            borderRadius: KuberShape.fullR),
                        alignment: Alignment.center,
                        child: Text('${l.ahdFilter}  3',
                            style: tt.labelLarge!
                                .copyWith(color: cs.onSecondaryContainer)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                          color: cs.surfaceContainerHigh,
                          borderRadius: KuberShape.fullR),
                      alignment: Alignment.center,
                      child: Text(l.ahdCategory,
                          style:
                              tt.labelLarge!.copyWith(color: cs.onSurface)),
                    ),
                  ]),
                  sampleRow(l.ahdCategory, 0.62),
                  sampleRow(l.ahdAccount, 0.38),
                  sampleRow(l.ahdTag, 0.21),
                  const SizedBox(height: KuberSpace.md),
                  Text(l.ahdGateSample,
                      style: tt.labelSmall!
                          .copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          const SizedBox(height: KuberSpace.xl),
          Container(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                  color: cs.tertiaryContainer, borderRadius: KuberShape.fullR),
              child: Text(l.ahdGatePill,
                  style: tt.labelMedium!
                      .copyWith(color: cs.onTertiaryContainer)),
            ),
          ),
          const SizedBox(height: KuberSpace.md),
          Text(l.ahdGateHeadline,
              style: tt.headlineSmall!.copyWith(color: cs.onSurface)),
          const SizedBox(height: KuberSpace.lg),
          for (final b in benefits)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.check_circle_outline_rounded,
                      size: 20, color: cs.primary),
                  const SizedBox(width: KuberSpace.md),
                  Expanded(
                    child: Text(b,
                        style: localeFont(
                            fontSize: 15,
                            color: cs.onSurfaceVariant,
                            height: 1.35)),
                  ),
                ],
              ),
            ),
          const SizedBox(height: KuberSpace.xl),
          AppButton(
            label: l.ahdGateCta,
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: () => context.push('/pro'),
          ),
        ],
      ),
    );
  }
}

/// The real page (Pro): app bar, then the start screen or the dashboard.
class AhPage extends ConsumerWidget {
  const AhPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final isStart = ref.watch(ahViewProvider.select((v) => v.isStart));
    final reduced = AhMotion.reduced(context);
    return Scaffold(
      appBar: KuberAppBar(
        title: l.ahdTitle,
        showBack: true,
        actions: const [_Overflow()],
      ),
      body: AnimatedSwitcher(
        duration: reduced ? AhMotion.instant : AhMotion.fast,
        reverseDuration: AhMotion.instant,
        switchInCurve: AhMotion.decelerate,
        transitionBuilder: (child, anim) => FadeTransition(
          opacity: anim,
          child: SlideTransition(
                  position: Tween<Offset>(
                          begin: reduced ? Offset.zero : const Offset(0, 0.012), end: Offset.zero)
                      .animate(anim),
                  child: child,
                ),
        ),
        child: isStart
            ? const AhStartScreen(key: ValueKey('start'))
            : const _Dashboard(key: ValueKey('dash')),
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    const gutter = EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin);
    return CustomScrollView(
      primary: false,
      slivers: [
        const SliverToBoxAdapter(
          child: AhFadeIn(
            child: Padding(
              padding: EdgeInsets.fromLTRB(KuberSpace.screenMargin,
                  KuberSpace.sm, KuberSpace.screenMargin, KuberSpace.md),
              child: AhActionRow(),
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(padding: gutter, child: AhChangeBar()),
        ),
        const SliverToBoxAdapter(
          child: AhFadeIn(
            delay: Duration(milliseconds: 30),
            child: Padding(
              padding: EdgeInsets.only(bottom: KuberSpace.md),
              child: AhKpiRow(),
            ),
          ),
        ),
        const AhChartsArea(),
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(KuberSpace.screenMargin, 0,
              KuberSpace.screenMargin, KuberSpace.xxxl),
          sliver: AhResults(),
        ),
      ],
    );
  }
}

class _Overflow extends ConsumerWidget {
  const _Overflow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return Builder(
      builder: (anchor) => AppIconButton(
        icon: Icons.more_vert_rounded,
        semanticLabel: l.ahdTitle,
        onPressed: () async {
          final v = ref.read(ahViewProvider);
          final saved = ref.read(savedFiltersProvider).valueOrNull?.length ?? 0;
          final n = v.isStart
              ? 0
              : (ref.read(ahKpisProvider).valueOrNull?.transactions ?? 0);
          final pick = await showKuberMenu<String>(
            context: anchor,
            minWidth: 240,
            entries: [
              KuberMenuEntry(
                  value: 'saved',
                  label: l.ahdMenuSaved,
                  subtitle: l.ahdSavedN(saved),
                  icon: Icons.bookmarks_outlined),
              KuberMenuEntry(
                  value: v.hasAnything ? 'save' : null,
                  label: l.ahdMenuSave,
                  icon: Icons.bookmark_add_outlined),
              KuberMenuEntry(
                  value: n > 0 ? 'export' : null,
                  label: l.ahdMenuExport,
                  subtitle: l.ahdTxnN(n),
                  icon: Icons.ios_share_rounded),
              if (v.hasAnything)
                KuberMenuEntry(
                    value: 'clear',
                    label: l.ahdMenuClear,
                    icon: Icons.filter_alt_off_outlined),
              const KuberMenuEntry.divider(),
              KuberMenuEntry(
                  value: 'help',
                  label: l.ahdMenuHelp,
                  icon: Icons.help_outline_rounded),
            ],
          );
          if (!context.mounted) return;
          switch (pick) {
            case 'saved':
              showAhSavedSheet(context);
            case 'save':
              showAhNameSheet(context, mode: AhNameMode.save);
            case 'export':
              showAhExportSheet(context);
            case 'clear':
              ahConfirmClearAll(context, ref);
            case 'help':
              showAhHelpSheet(context);
          }
        },
      ),
    );
  }
}
