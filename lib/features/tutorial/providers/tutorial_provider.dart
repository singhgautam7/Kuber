import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/tutorial_chapter.dart';

final tutorialNotifierProvider =
    StateNotifierProvider<TutorialNotifier, TutorialState>(
      TutorialNotifier.new,
    );

class TutorialState {
  final int chapterIndex;
  final int stepIndex;
  final bool isActive;
  final bool isSandboxMode;
  final Set<int> completedChapters;

  const TutorialState({
    this.chapterIndex = 0,
    this.stepIndex = 0,
    this.isActive = false,
    this.isSandboxMode = false,
    this.completedChapters = const {},
  });

  TutorialChapter get chapter => tutorialChapters[chapterIndex];
  TutorialStep get step => chapter.steps[stepIndex];
  bool get isFirstStep => chapterIndex == 0 && stepIndex == 0;
  bool get isLastStep =>
      chapterIndex == tutorialChapters.length - 1 &&
      stepIndex == tutorialChapters.last.steps.length - 1;

  TutorialState copyWith({
    int? chapterIndex,
    int? stepIndex,
    bool? isActive,
    bool? isSandboxMode,
    Set<int>? completedChapters,
  }) {
    return TutorialState(
      chapterIndex: chapterIndex ?? this.chapterIndex,
      stepIndex: stepIndex ?? this.stepIndex,
      isActive: isActive ?? this.isActive,
      isSandboxMode: isSandboxMode ?? this.isSandboxMode,
      completedChapters: completedChapters ?? this.completedChapters,
    );
  }
}

class TutorialNotifier extends StateNotifier<TutorialState> {
  TutorialNotifier(this.ref) : super(const TutorialState());

  final Ref ref;

  void setSandboxMode(bool value) {
    state = state.copyWith(isSandboxMode: value);
  }

  void startFromChapter(int index) {
    final safeIndex = index.clamp(0, tutorialChapters.length - 1);
    state = state.copyWith(
      chapterIndex: safeIndex,
      stepIndex: 0,
      isActive: true,
    );
  }

  bool nextStep() {
    if (state.isLastStep) return false;

    final chapter = state.chapter;
    if (state.stepIndex < chapter.steps.length - 1) {
      state = state.copyWith(stepIndex: state.stepIndex + 1);
      return true;
    }

    final completed = {...state.completedChapters, state.chapterIndex};
    state = state.copyWith(
      chapterIndex: state.chapterIndex + 1,
      stepIndex: 0,
      completedChapters: completed,
    );
    return true;
  }

  void prevStep() {
    if (state.isFirstStep) return;

    if (state.stepIndex > 0) {
      state = state.copyWith(stepIndex: state.stepIndex - 1);
      return;
    }

    final previousChapterIndex = state.chapterIndex - 1;
    state = state.copyWith(
      chapterIndex: previousChapterIndex,
      stepIndex: tutorialChapters[previousChapterIndex].steps.length - 1,
    );
  }

  void completeTutorial() {
    state = state.copyWith(
      isActive: false,
      completedChapters: {...state.completedChapters, state.chapterIndex},
    );
  }

  void stopTutorial() {
    state = state.copyWith(isActive: false);
  }
}
