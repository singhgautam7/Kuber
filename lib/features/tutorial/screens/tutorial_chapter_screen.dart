import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/brand_icon.dart';
import '../models/tutorial_chapter.dart';
import '../providers/tutorial_provider.dart';

class TutorialChapterScreen extends ConsumerWidget {
  const TutorialChapterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final notifier = ref.read(tutorialNotifierProvider.notifier);
    final state = ref.watch(tutorialNotifierProvider);
    final chapters = TutorialChapter.allChapters;

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpacing.xl,
                KuberSpacing.xl,
                KuberSpacing.xl,
                0,
              ),
              child: Row(
                children: [
                  const BrandIcon(size: 32, useImage: true),
                  const SizedBox(width: KuberSpacing.sm),
                  Text(
                    'TUTORIAL',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.5,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 36,
                    height: 36,
                    child: OutlinedButton(
                      onPressed: () => context.go('/'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        side: BorderSide(color: cs.outline),
                        shape: const CircleBorder(),
                      ),
                      child: Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Headline
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpacing.xl,
                KuberSpacing.xl,
                KuberSpacing.xl,
                KuberSpacing.sm,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pick a chapter.',
                    style: GoogleFonts.inter(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      letterSpacing: -0.9,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: KuberSpacing.sm),
                  Text(
                    'Five quick chapters, ~2 minutes each. Jump in anywhere.',
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: cs.onSurfaceVariant,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),

            // Chapter cards
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.xl,
                  vertical: KuberSpacing.md,
                ),
                itemCount: chapters.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: KuberSpacing.md),
                itemBuilder: (context, index) {
                  final chapter = chapters[index];
                  final isCurrent = state.isActive &&
                      state.chapterIndex == index;

                  return _ChapterCard(
                    chapter: chapter,
                    index: index,
                    isCurrent: isCurrent,
                    onTap: () {
                      notifier.startFromChapter(index);
                      context.go(chapter.navigateTo);
                    },
                  );
                },
              ),
            ),

            // Bottom bar
            Padding(
              padding: const EdgeInsets.all(KuberSpacing.xl),
              child: Row(
                children: [
                  OutlinedButton(
                    onPressed: () => notifier.skipTutorial(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: cs.onSurface,
                      side: BorderSide(color: cs.outline),
                      padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.lg,
                        vertical: KuberSpacing.md,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                    ),
                    child: Text(
                      'Maybe later',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  const SizedBox(width: KuberSpacing.md),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: () {
                          notifier.startFromChapter(0);
                          context.go(chapters[0].navigateTo);
                        },
                        style: FilledButton.styleFrom(
                          backgroundColor: cs.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(KuberRadius.md),
                          ),
                        ),
                        child: Text(
                          'Start from beginning →',
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final TutorialChapter chapter;
  final int index;
  final bool isCurrent;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
    required this.index,
    required this.isCurrent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: isCurrent
              ? cs.primary.withValues(alpha: 0.08)
              : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: isCurrent ? cs.primary : cs.outline,
            width: isCurrent ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            // Emoji icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberRadius.md),
                border: Border.all(color: cs.outline),
              ),
              child: Center(
                child: Text(
                  chapter.emoji,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
            ),
            const SizedBox(width: KuberSpacing.md),

            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    chapter.description,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${chapter.steps.length} steps · ${chapter.estimatedTime}',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),

            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
