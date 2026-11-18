import 'package:flutter/foundation.dart';

/// Whether the Dev Tools may grant or reset a trial. Debug builds only (not
/// `KUBER_QA`), so a release build can never grant or reset one. Tests flip it.
bool debugTrialToolsAllowed = kDebugMode;
