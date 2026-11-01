import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:isar_community/isar.dart';
import 'package:kuber/core/database/isar_service.dart';
import 'package:kuber/features/sms_import/data/sms_import_repository.dart';
import 'package:kuber/features/sms_import/data/sms_transaction.dart';
import 'package:kuber/features/sms_import/engine/scan_progress.dart';
import 'package:kuber/features/sms_import/providers/sms_import_provider.dart';
import 'package:kuber/features/sms_import/providers/sms_today_summary.dart';
import 'package:kuber/features/sms_import/services/sms_inbox_service.dart';
import 'package:kuber/features/tutorial/providers/tutorial_sandbox_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/isar_test_helper.dart';

final _now = DateTime(2026, 10, 31, 15, 0);

SmsTransaction _sms(
  double amount,
  DateTime date, {
  String type = 'expense',
  String status = SmsReviewStatus.unreviewed,
}) {
  final raw = 'sms ${date.microsecondsSinceEpoch} $amount $type ${_n++}';
  return SmsTransaction()
    ..rawSms = raw
    ..senderId = 'HDFCBK'
    ..rawSmsHash = raw.hashCode.toString()
    ..parsedDate = date
    ..parsedAmount = amount
    ..parsedType = type
    ..parsedMerchant = 'M'
    ..parsedAccountSuffix = '4521'
    ..reviewStatus = status
    ..smsDate = date
    ..patternMatched = 'p';
}

int _n = 0;

SmsTodaySummary _compute({
  List<SmsTransaction> unreviewed = const [],
  List<SmsTransaction> imported = const [],
  List<SmsTransaction> dismissed = const [],
  DateTime? now,
}) =>
    computeSmsTodaySummary(
      unreviewed: unreviewed,
      imported: imported,
      dismissed: dismissed,
      now: now ?? _now,
    );

final _today = DateTime(2026, 10, 31, 9, 0);
final _yesterday = DateTime(2026, 10, 30, 12, 0);

class _FakeInbox extends SmsInboxService {
  _FakeInbox({this.permission = true});
  final bool permission;
  int reads = 0;

  @override
  bool get isSupported => true;

  @override
  Future<bool> checkPermission() async => permission;

  @override
  Future<List<RawInboxSms>> readRawInbox({int? days, DateTime? since}) async {
    reads++;
    await Future<void>.delayed(const Duration(milliseconds: 50));
    return const [];
  }
}

void main() {
  group('computeSmsTodaySummary', () {
    test('1 debits only', () {
      final s = _compute(
          unreviewed: [_sms(412, _today), _sms(1299, _today)]);
      expect(s.spent, 1711);
      expect(s.received, 0);
      expect(s.count, 2);
      expect(s.state, SmsTodayState.untracked);
    });

    test('2 credits only', () {
      final s = _compute(unreviewed: [_sms(12000, _today, type: 'income')]);
      expect(s.received, 12000);
      expect(s.spent, 0);
    });

    test('3 both kinds stay separate', () {
      final s = _compute(unreviewed: [
        _sms(412, _today),
        _sms(289, _today),
        _sms(12000, _today, type: 'income'),
      ]);
      expect(s.spent, 701);
      expect(s.received, 12000);
      expect(s.spent, isNot(s.spent + s.received));
    });

    test('4 no amount counted but not summed', () {
      final s = _compute(unreviewed: [_sms(412, _today), _sms(0, _today)]);
      expect(s.count, 2);
      expect(s.noAmount, 1);
      expect(s.spent, 412);
    });

    test('5 midnight boundary', () {
      final s = _compute(unreviewed: [
        _sms(1, DateTime(2026, 10, 30, 23, 59, 59)),
        _sms(2, DateTime(2026, 10, 31, 0, 0, 0)),
        _sms(3, DateTime(2026, 10, 31, 0, 0, 1)),
      ]);
      expect(s.count, 2);
      expect(s.spent, 5);
      expect(s.day, DateTime(2026, 10, 31));
    });

    test('6 zero today, nothing reviewed today -> none', () {
      final s = _compute(
        unreviewed: [_sms(1, _yesterday)],
        imported: [_sms(1, _yesterday)],
        dismissed: [_sms(1, _yesterday)],
      );
      expect(s.count, 0);
      expect(s.state, SmsTodayState.none);
    });

    test('7 zero today, reviewed today -> caughtUp', () {
      expect(_compute(imported: [_sms(1, _today)]).state,
          SmsTodayState.caughtUp);
      expect(_compute(dismissed: [_sms(1, _today)]).state,
          SmsTodayState.caughtUp);
    });

    test('8 count dropping to zero', () {
      final row = _sms(100, _today);
      final a = _compute(unreviewed: [row]);
      expect(a.state, SmsTodayState.untracked);
      expect(a.count, 1);
      final b = _compute(dismissed: [row]);
      expect(b.state, SmsTodayState.caughtUp);
      expect(b.count, 0);
      expect(b.spent, 0);
    });

    test('9 day rollover', () {
      final rows = [_sms(100, _today)];
      final next = DateTime(2026, 11, 1, 8, 0);
      final s = _compute(unreviewed: rows, now: next);
      expect(s.count, 0);
      expect(s.spent, 0);
      expect(s.day, DateTime(2026, 11, 1));
    });

    test('10 equality and hashCode', () {
      final a = _compute(unreviewed: [_sms(100, _today)]);
      final b = _compute(unreviewed: [_sms(100, _today)]);
      final c = _compute(unreviewed: [_sms(101, _today)]);
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('with Isar', () {
    late Isar isar;
    late ProviderContainer container;

    setUpAll(initialiseIsarForTests);

    ProviderContainer makeContainer({SmsInboxService? inbox}) =>
        ProviderContainer(overrides: [
          isarProvider.overrideWithValue(isar),
          tutorialAwareIsarProvider.overrideWithValue(isar),
          if (inbox != null) smsInboxServiceProvider.overrideWithValue(inbox),
        ]);

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      isar = await openTestIsar();
      container = makeContainer();
    });

    tearDown(() async {
      container.dispose();
      await closeAndCleanIsar(isar);
    });

    test('11 provider follows dismissBatch / undoDismissBatch', () async {
      final repo = container.read(smsImportRepositoryProvider);
      final now = DateTime.now();
      final ids = <int>[];
      for (final r in [
        _sms(100, now),
        _sms(200, now),
        _sms(500, now, type: 'income'),
        _sms(900, now.subtract(const Duration(days: 2))),
      ]) {
        ids.add(await repo.put(r));
      }
      await container.read(smsImportProvider.future);
      final notifier = container.read(smsImportProvider.notifier);

      var s = container.read(smsTodaySummaryProvider)!;
      expect((s.spent, s.received, s.count), (300, 500, 3));

      await notifier.dismissBatch(ids);
      s = container.read(smsTodaySummaryProvider)!;
      expect(s.state, SmsTodayState.caughtUp);
      expect(s.count, 0);

      await notifier.undoDismissBatch(ids);
      s = container.read(smsTodaySummaryProvider)!;
      expect((s.spent, s.received, s.count), (300, 500, 3));
      final rows = await isar.smsTransactions.getAll(ids);
      expect(rows.every((r) => r!.reviewStatus == SmsReviewStatus.unreviewed),
          isTrue);
    });

    test('12 repository batch moves exactly the given rows', () async {
      final repo = container.read(smsImportRepositoryProvider);
      final all = <int>[];
      for (var i = 0; i < 300; i++) {
        all.add(await repo.put(_sms(i + 1.0, _today)));
      }
      Future<List<int>> idsWith(String st) async => (await isar.smsTransactions
              .filter()
              .reviewStatusEqualTo(st)
              .findAll())
          .map((e) => e.id)
          .toList()
        ..sort();

      await repo.markDismissedBatch([all[0]]);
      expect(await idsWith(SmsReviewStatus.dismissed), [all[0]]);

      final big = all.sublist(10, 260);
      expect(big.length, 250);
      await repo.markDismissedBatch(big);
      expect(await idsWith(SmsReviewStatus.dismissed),
          ([all[0], ...big]..sort()));
      expect((await idsWith(SmsReviewStatus.unreviewed)).length, 49);

      await repo.markUnreviewedBatch(big);
      expect(await idsWith(SmsReviewStatus.dismissed), [all[0]]);

      await repo.markDismissedBatch([999991, 999992]);
      await repo.markUnreviewedBatch([999991, all[0]]);
      expect((await idsWith(SmsReviewStatus.unreviewed)).length, 300);
    });

    test('13 scan dedupe, once per session, session flag', () async {
      final fake = _FakeInbox();
      container.dispose();
      container = makeContainer(inbox: fake);
      await container.read(smsImportProvider.future);
      final notifier = container.read(smsImportProvider.notifier);
      expect(container.read(smsScannedThisSessionProvider), isFalse);

      // (a) concurrent calls join one scan.
      final f1 = notifier.startBackgroundScan();
      final f2 = notifier.startBackgroundScan();
      await Future.wait([f1, f2]);
      expect(fake.reads, 1);
      // (c)
      expect(container.read(smsScannedThisSessionProvider), isTrue);

      // (b) fresh container: autoRefreshOnce twice -> exactly one read.
      final fake2 = _FakeInbox();
      final c2 = makeContainer(inbox: fake2);
      addTearDown(c2.dispose);
      await c2.read(smsImportProvider.future);
      final n2 = c2.read(smsImportProvider.notifier);
      await n2.autoRefreshOnce();
      await n2.autoRefreshOnce();
      expect(fake2.reads, 1);
    });

    test('14 permission missing: no read, flag stays false', () async {
      final fake = _FakeInbox(permission: false);
      container.dispose();
      container = makeContainer(inbox: fake);
      await container.read(smsImportProvider.future);
      await container.read(smsImportProvider.notifier).autoRefreshOnce();
      expect(fake.reads, 0);
      expect(container.read(smsScannedThisSessionProvider), isFalse);
    });
  });
}
