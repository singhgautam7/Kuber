import 'package:isar_community/isar.dart';
import 'package:kuber/core/background/occurrence_processor.dart';
import 'package:kuber/core/database/vnext_migration.dart';
import 'package:kuber/l10n/app_localizations_en.dart';

/// What the old `RecurringProcessor.processAll()` did, through the vNext
/// path: migrate any legacy rows, then post due occurrences. Returns the
/// number of transactions posted.
Future<int> processDue(Isar isar, {DateTime? now}) async {
  await VNextMigration.run(isar, now: now);
  final s = await OccurrenceProcessor(isar, decimals: 2, l10n: AppLocalizationsEn())
      .run(now: now);
  return s.posted;
}
