// Index-based localized accessors for tutorialChapters (data stays English in
// tutorial_chapter.dart; the chapter/step ORDER is the contract). Display sites
// pass the chapter/step index from TutorialState.
import 'package:flutter/widgets.dart';
import 'package:kuber/core/utils/l10n_ext.dart';

String tutChapterTitle(BuildContext context, int c) {
  final l = context.l10n;
  switch (c) {
    case 0: return l.tutCh0Title;
    case 1: return l.tutCh1Title;
    case 2: return l.tutCh2Title;
    case 3: return l.tutCh3Title;
    case 4: return l.tutCh4Title;
    default: return '';
  }
}

String tutChapterDesc(BuildContext context, int c) {
  final l = context.l10n;
  switch (c) {
    case 0: return l.tutCh0Desc;
    case 1: return l.tutCh1Desc;
    case 2: return l.tutCh2Desc;
    case 3: return l.tutCh3Desc;
    case 4: return l.tutCh4Desc;
    default: return '';
  }
}

String tutStepTitle(BuildContext context, int c, int s) {
  final l = context.l10n;
  switch (c) {
    case 0: switch (s) {
      case 0: return l.tutCh0St0Title;
      case 1: return l.tutCh0St1Title;
      case 2: return l.tutCh0St2Title;
      case 3: return l.tutCh0St3Title;
      case 4: return l.tutCh0St4Title;
      case 5: return l.tutCh0St5Title;
      case 6: return l.tutCh0St6Title;
      case 7: return l.tutCh0St7Title;
      default: return '';
    }
    case 1: switch (s) {
      case 0: return l.tutCh1St0Title;
      case 1: return l.tutCh1St1Title;
      case 2: return l.tutCh1St2Title;
      case 3: return l.tutCh1St3Title;
      case 4: return l.tutCh1St4Title;
      default: return '';
    }
    case 2: switch (s) {
      case 0: return l.tutCh2St0Title;
      case 1: return l.tutCh2St1Title;
      case 2: return l.tutCh2St2Title;
      case 3: return l.tutCh2St3Title;
      default: return '';
    }
    case 3: switch (s) {
      case 0: return l.tutCh3St0Title;
      case 1: return l.tutCh3St1Title;
      case 2: return l.tutCh3St2Title;
      case 3: return l.tutCh3St3Title;
      case 4: return l.tutCh3St4Title;
      default: return '';
    }
    case 4: switch (s) {
      case 0: return l.tutCh4St0Title;
      case 1: return l.tutCh4St1Title;
      case 2: return l.tutCh4St2Title;
      default: return '';
    }
    default: return '';
  }
}

String tutStepDesc(BuildContext context, int c, int s) {
  final l = context.l10n;
  switch (c) {
    case 0: switch (s) {
      case 0: return l.tutCh0St0Desc;
      case 1: return l.tutCh0St1Desc;
      case 2: return l.tutCh0St2Desc;
      case 3: return l.tutCh0St3Desc;
      case 4: return l.tutCh0St4Desc;
      case 5: return l.tutCh0St5Desc;
      case 6: return l.tutCh0St6Desc;
      case 7: return l.tutCh0St7Desc;
      default: return '';
    }
    case 1: switch (s) {
      case 0: return l.tutCh1St0Desc;
      case 1: return l.tutCh1St1Desc;
      case 2: return l.tutCh1St2Desc;
      case 3: return l.tutCh1St3Desc;
      case 4: return l.tutCh1St4Desc;
      default: return '';
    }
    case 2: switch (s) {
      case 0: return l.tutCh2St0Desc;
      case 1: return l.tutCh2St1Desc;
      case 2: return l.tutCh2St2Desc;
      case 3: return l.tutCh2St3Desc;
      default: return '';
    }
    case 3: switch (s) {
      case 0: return l.tutCh3St0Desc;
      case 1: return l.tutCh3St1Desc;
      case 2: return l.tutCh3St2Desc;
      case 3: return l.tutCh3St3Desc;
      case 4: return l.tutCh3St4Desc;
      default: return '';
    }
    case 4: switch (s) {
      case 0: return l.tutCh4St0Desc;
      case 1: return l.tutCh4St1Desc;
      case 2: return l.tutCh4St2Desc;
      default: return '';
    }
    default: return '';
  }
}

