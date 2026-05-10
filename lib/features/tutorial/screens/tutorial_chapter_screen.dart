import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/brand_icon.dart';
import '../models/tutorial_chapter.dart';
import '../providers/tutorial_provider.dart';
import '../providers/tutorial_sandbox_provider.dart';

class TutorialChapterScreen extends ConsumerWidget {
  const TutorialChapterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(tutorialNotifierProvider);

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(KuberSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BrandIcon(size: 36),
                  const SizedBox(width: KuberSpacing.md),
                  Text(
                    'TUTORIAL',
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurfaceVariant,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const Spacer(),
                  IconButton.outlined(
                    onPressed: () => _confirmSkip(context, ref),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.xxl),
              Text(
                'Pick a chapter.',
                style: GoogleFonts.inter(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: cs.onSurface,
                  letterSpacing: -0.8,
                ),
              ),
              const SizedBox(height: KuberSpacing.sm),
              Text(
                'Five quick chapters, about 2 minutes each. Jump in anywhere.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: cs.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: KuberSpacing.xl),
              Expanded(
                child: ListView.separated(
                  itemCount: tutorialChapters.length,
                  separatorBuilder: (_, __) =>
                      const SizedBox(height: KuberSpacing.md),
                  itemBuilder: (context, index) {
                    final chapter = tutorialChapters[index];
                    return _ChapterCard(
                      chapter: chapter,
                      selected: state.isActive && state.chapterIndex == index,
                      completed: state.completedChapters.contains(index),
                      onTap: () => _startChapter(context, ref, index),
                    );
                  },
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        onPressed: () => _confirmSkip(context, ref),
                        child: const Text('Maybe later'),
                      ),
                    ),
                  ),
                  const SizedBox(width: KuberSpacing.md),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: () => _startChapter(context, ref, 0),
                        child: const Text('Start from beginning →'),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _startChapter(BuildContext context, WidgetRef ref, int index) {
    ref.read(tutorialNotifierProvider.notifier).startFromChapter(index);
    context.go(tutorialChapters[index].route);
  }

  Future<void> _confirmSkip(BuildContext context, WidgetRef ref) async {
    final skip = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Skip tutorial?'),
        content: const Text('You can always replay it from More → Tutorial.'),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep going'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Skip'),
          ),
        ],
      ),
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
  final bool selected;
  final bool completed;
  final VoidCallback onTap;

  const _ChapterCard({
    required this.chapter,
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
        borderRadius: BorderRadius.circular(KuberRadius.md),
        child: Ink(
          padding: const EdgeInsets.all(KuberSpacing.lg),
          decoration: BoxDecoration(
            color: selected
                ? cs.primary.withValues(alpha: 0.08)
                : cs.surfaceContainer,
            borderRadius: BorderRadius.circular(KuberRadius.md),
            border: Border.all(color: selected ? cs.primary : cs.outline),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: cs.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: cs.outline),
                ),
                child: Text(
                  chapter.emoji,
                  style: const TextStyle(fontSize: 22),
                ),
              ),
              const SizedBox(width: KuberSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chapter.title,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                            ),
                          ),
                        ),
                        if (completed)
                          Icon(
                            Icons.check_circle_rounded,
                            color: cs.tertiary,
                            size: 18,
                          ),
                      ],
                    ),
                    const SizedBox(height: KuberSpacing.xs),
                    Text(
                      chapter.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        height: 1.35,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.xs),
                    Text(
                      '${chapter.steps.length} steps · ${chapter.estimate}',
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
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
