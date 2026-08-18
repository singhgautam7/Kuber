import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/utils/prefs_keys.dart';
import 'package:kuber/features/sms_import/data/sms_import_usage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fresh install has a full allowance and no active window', () async {
    SharedPreferences.setMockInitialValues({});
    expect(await SmsImportUsage.importsThisWeek(), 0);
    expect(await SmsImportUsage.remainingThisWeek(), smsImportFreeWeeklyLimit);
    expect(await SmsImportUsage.atWeeklyLimit(), isFalse);
    expect(await SmsImportUsage.resetDate(), isNull);
  });

  test('increment accumulates within the window and shrinks remaining', () async {
    SharedPreferences.setMockInitialValues({});
    await SmsImportUsage.increment(1);
    expect(await SmsImportUsage.importsThisWeek(), 1);
    expect(await SmsImportUsage.remainingThisWeek(), 4);

    await SmsImportUsage.increment(3);
    expect(await SmsImportUsage.importsThisWeek(), 4);
    expect(await SmsImportUsage.remainingThisWeek(), 1);
    expect(await SmsImportUsage.atWeeklyLimit(), isFalse);
  });

  test('reaching the limit reports atWeeklyLimit and zero remaining', () async {
    SharedPreferences.setMockInitialValues({});
    await SmsImportUsage.increment(smsImportFreeWeeklyLimit);
    expect(await SmsImportUsage.atWeeklyLimit(), isTrue);
    expect(await SmsImportUsage.remainingThisWeek(), 0);
  });

  test('a lapsed window (>= 7 days old) self-resets to a full allowance', () async {
    final eightDaysAgo =
        DateTime.now().subtract(const Duration(days: 8)).toIso8601String();
    SharedPreferences.setMockInitialValues({
      PrefsKeys.smsImportWindowStart: eightDaysAgo,
      PrefsKeys.smsImportWindowCount: smsImportFreeWeeklyLimit,
    });
    expect(await SmsImportUsage.importsThisWeek(), 0);
    expect(await SmsImportUsage.remainingThisWeek(), smsImportFreeWeeklyLimit);
    expect(await SmsImportUsage.resetDate(), isNull);

    // The next import re-anchors the window to now.
    await SmsImportUsage.increment(1);
    expect(await SmsImportUsage.importsThisWeek(), 1);
    final reset = await SmsImportUsage.resetDate();
    expect(reset, isNotNull);
    expect(reset!.isAfter(DateTime.now()), isTrue);
  });

  test('an active window keeps its count and exposes a reset date', () async {
    final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
    SharedPreferences.setMockInitialValues({
      PrefsKeys.smsImportWindowStart: twoDaysAgo.toIso8601String(),
      PrefsKeys.smsImportWindowCount: 3,
    });
    expect(await SmsImportUsage.importsThisWeek(), 3);
    expect(await SmsImportUsage.remainingThisWeek(), 2);
    final reset = await SmsImportUsage.resetDate();
    expect(reset, isNotNull);
    // reset == windowStart + 7d, i.e. ~5 days out from now.
    expect(reset!.isAfter(DateTime.now().add(const Duration(days: 4))), isTrue);
  });
}
