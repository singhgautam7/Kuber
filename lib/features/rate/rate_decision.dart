/// Cold starts on which the sheet may show. A skipped launch is not carried over.
const rateLaunches = {2, 4, 8, 16};

/// The whole decision, pure.
bool shouldShowRatePrompt({
  required int launchCount,
  required bool neverShow,
  required bool rateTapped,
  required bool inWelcomeFlow,
  required bool openedExternally,
  required bool somethingOnTop,
}) =>
    rateLaunches.contains(launchCount) &&
    !neverShow &&
    !rateTapped &&
    !inWelcomeFlow &&
    !openedExternally &&
    !somethingOnTop;

