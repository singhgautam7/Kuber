import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../models/tutorial_chapter.dart';
import '../models/tutorial_l10n.dart';
import '../providers/tutorial_provider.dart';
import '../providers/tutorial_sandbox_provider.dart';

class TutorialChapterScreen extends ConsumerWidget {
  const TutorialChapterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(tutorialNotifierProvider);

    // The app's header (back + title). Back keeps the old close
    // behaviour: confirm, then leave the tutorial.
    return Scaffold(
      backgroundColor: cs.surface,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KuberAppBar(
            title: sentenceCase(context.l10n.tutorialUpper),
            showBack: true,
            onBack: () => _confirmSkip(context, ref),
          ),
          Expanded(
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpace.screenMargin,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Scrollable list with heading as first item
                    Expanded(
                      child: ListView.separated(
                        itemCount: tutorialChapters.length + 1,
                        separatorBuilder: (_, index) => index == 0
                            ? const SizedBox(height: KuberSpace.xl)
                            : const SizedBox(height: KuberSpace.md),
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.pickChapter,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall!
                                      .copyWith(color: cs.onSurface),
                                ),
                                const SizedBox(height: KuberSpace.sm),
                                Text(
                                  context.l10n.pickChapterSubtitle,
                                  style: Theme.of(context).textTheme.bodyMedium!
                                      .copyWith(color: cs.onSurfaceVariant),
                                ),
                              ],
                            );
                          }
                          final chapter = tutorialChapters[index - 1];
                          final chapterIndex = index - 1;
                          return _ChapterCard(
                            chapter: chapter,
                            chapterIndex: chapterIndex,
                            selected:
                                state.isActive &&
                                state.chapterIndex == chapterIndex,
                            completed: state.completedChapters.contains(
                              chapterIndex,
                            ),
                            onTap: () =>
                                _startChapter(context, ref, chapterIndex),
                          );
                        },
                      ),
                    ),

                    // Bottom CTA — full-width single button
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: KuberSpace.lg,
                      ),
                      child: SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: FilledButton(
                          onPressed: () => _startChapter(context, ref, 0),
                          child: Text(context.l10n.startFromBeginning),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startChapter(BuildContext context, WidgetRef ref, int index) {
    ref.read(tutorialNotifierProvider.notifier).startFromChapter(index);
    context.go(tutorialChapters[index].route);
  }

  Future<void> _confirmSkip(BuildContext context, WidgetRef ref) async {
    final skip = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (sheetCtx) {
        final cs = Theme.of(sheetCtx).colorScheme;
        return KuberBottomSheet(
          title: context.l10n.skipTutorialConfirm,
          actions: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.of(sheetCtx, rootNavigator: true).pop(false),
                    child: Text(context.l10n.keepGoing),
                  ),
                ),
              ),
              SizedBox(width: KuberSpace.md),
              Expanded(
                child: SizedBox(
                  height: 48,
                  child: FilledButton(
                    onPressed: () =>
                        Navigator.of(sheetCtx, rootNavigator: true).pop(true),
                    child: Text(context.l10n.skipLabel),
                  ),
                ),
              ),
            ],
          ),
          child: Text(
            context.l10n.replayHint,
            style: localeFont(
              fontSize: 14,
              height: 1.5,
              color: cs.onSurfaceVariant,
            ),
          ),
        );
      },
    );

    if (skip == true && context.mounted) {
      final sandbox = ref.read(tutorialSandboxIsarProvider);
      if (sandbox != null) {
        await closeSandboxIsar(sandbox);
        ref.read(tutorialSandboxIsarProvider.notifier).state = null;
      }
      if (!context.mounted) return;
      ref.read(tutorialNotifierProvider.notifier).stopTutorial();
      context.go('/');
    }
  }
}

class _ChapterCard extends StatelessWidget {
  final TutorialChapter chapter;
  final int chapterIndex;
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.chapterIndex,
    required this.selected,
    required this.completed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(KuberShape.medium),
        child: Ink(
          padding: const EdgeInsets.all(KuberSpace.lg),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.08)
                : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
            border: Border.all(
              color: selected ? cs.primary : cs.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              KuberIconTile(
                icon: chapter.icon,
                tone: selected ? KuberTone.primary : KuberTone.secondary,
                size: 44,
                glyph: 22,
              ),
              const SizedBox(width: KuberSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            tutChapterTitle(context, chapterIndex),
                            style: localeFont(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        if (completed)
                          Icon(
                            Icons.check_circle_rounded,
                            color: context.kuberMoney.income,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: KuberSpace.xs),
                    Text(
                      tutChapterDesc(context, chapterIndex),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: localeFont(
                        fontSize: 12,
                        height: 1.35,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: KuberSpace.xs),
                    Text(
                      context.l10n.tutStepsAndMin(
                        '${chapter.steps.length}',
                        chapter.steps.length <= 4 ? '1' : '2',
                      ),
                      style: localeFont(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
