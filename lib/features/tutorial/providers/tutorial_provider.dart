import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_loader.dart';
import '../models/tutorial_chapter.dart';
import '../services/tutorial_mock_data_service.dart';
import 'tutorial_sandbox_provider.dart';

class TutorialState {
  final int chapterIndex;
  final int stepIndex;
  final bool isActive;
  final bool isSandboxMode;

  const TutorialState({
    this.chapterIndex = 0,
    this.stepIndex = 0,
    this.isActive = false,
    this.isSandboxMode = false,
  });

  TutorialState copyWith({
    int? chapterIndex,
    int? stepIndex,
    bool? isActive,
    bool? isSandboxMode,
  }) {
    return TutorialState(
      chapterIndex: chapterIndex ?? this.chapterIndex,
      stepIndex: stepIndex ?? this.stepIndex,
      isActive: isActive ?? this.isActive,
      isSandboxMode: isSandboxMode ?? this.isSandboxMode,
    );
  }

  TutorialChapter get currentChapter =>
      TutorialChapter.allChapters[chapterIndex];

  TutorialStep get currentStep => currentChapter.steps[stepIndex];

  bool get isLastStep =>
      chapterIndex == TutorialChapter.allChapters.length - 1 &&
      stepIndex == currentChapter.steps.length - 1;

  bool get isFirstStep => chapterIndex == 0 && stepIndex == 0;
}

final tutorialNotifierProvider =
    NotifierProvider<TutorialNotifier, TutorialState>(TutorialNotifier.new);

class TutorialNotifier extends Notifier<TutorialState> {
  @override
  TutorialState build() => const TutorialState();

  void startFromChapter(int index) {
    state = state.copyWith(
      chapterIndex: index,
      stepIndex: 0,
      isActive: true,
    );
  }

  void nextStep() {
    final chapters = TutorialChapter.allChapters;
    final chapter = chapters[state.chapterIndex];

    if (state.stepIndex < chapter.steps.length - 1) {
      state = state.copyWith(stepIndex: state.stepIndex + 1);
    } else if (state.chapterIndex < chapters.length - 1) {
      state = state.copyWith(
        chapterIndex: state.chapterIndex + 1,
        stepIndex: 0,
      );
    }
  }

  void prevStep() {
    if (state.stepIndex > 0) {
      state = state.copyWith(stepIndex: state.stepIndex - 1);
    } else if (state.chapterIndex > 0) {
      final prevChapter =
          TutorialChapter.allChapters[state.chapterIndex - 1];
      state = state.copyWith(
        chapterIndex: state.chapterIndex - 1,
        stepIndex: prevChapter.steps.length - 1,
      );
    }
  }

  void setSandboxMode(bool value) {
    state = state.copyWith(isSandboxMode: value);
  }

  Future<void> skipTutorial(BuildContext context) async {
    final confirmed = await _showSkipDialog(context);
    if (confirmed && context.mounted) {
      await _endTutorial(context);
    }
  }

  Future<void> completeTutorial(BuildContext context) async {
    await _endTutorial(context);
  }

  Future<bool> _showSkipDialog(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cs.surfaceContainer,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(KuberRadius.md),
          side: BorderSide(color: cs.outline),
        ),
        title: Text(
          'Skip tutorial?',
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
        content: Text(
          'You can always replay it from More → Tutorial.',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: cs.onSurfaceVariant,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: cs.outline),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
            ),
            child: Text(
              'Keep going',
              style: GoogleFonts.inter(fontWeight: FontWeight.w600),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(KuberRadius.md),
              ),
            ),
            child: Text(
              'Skip',
              style: GoogleFonts.inter(
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _endTutorial(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const KuberLoader(label: 'Cleaning up...'),
    );

    final container = ProviderScope.containerOf(context, listen: false);
    final isar = container.read(tutorialAwareIsarProvider);

    await TutorialMockDataService().clearMockData(isar);

    if (state.isSandboxMode) {
      final sandbox = container.read(tutorialSandboxIsarProvider);
      if (sandbox != null) {
        await closeSandboxIsar(sandbox);
        container.read(tutorialSandboxIsarProvider.notifier).state = null;
      }
    }

    state = state.copyWith(isActive: false);

    if (context.mounted) {
      Navigator.of(context, rootNavigator: true).pop(); // dismiss loader
      context.go('/');
    }
  }
}
