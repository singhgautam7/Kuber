import 'package:flutter/widgets.dart';

import 'package:kuber/l10n/app_localizations.dart';

export 'package:kuber/l10n/app_localizations.dart';

/// Ergonomic access to the generated localizations from any widget:
/// `context.l10n.someKey`.
///
/// For code that has no [BuildContext] (providers, services, isolates) use
/// `lookupAppLocalizations(AppLocale.current)` instead.
extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
