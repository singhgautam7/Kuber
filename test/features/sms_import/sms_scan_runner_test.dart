import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/sms_import/engine/scan_progress.dart';
import 'package:kuber/features/sms_import/services/sms_scan_runner.dart';

List<RawInboxSms> _inbox({int bank = 60, int junk = 60}) {
  final list = <RawInboxSms>[];
  final ts = DateTime(2026, 6, 5).millisecondsSinceEpoch;
  for (var i = 0; i < bank; i++) {
    list.add(RawInboxSms(
      address: 'HDFCBK',
      body: 'INR 100.00 debited from A/c XX1234 on 05-Jun-26',
      dateMillis: ts,
    ));
  }
  for (var i = 0; i < junk; i++) {
    list.add(RawInboxSms(
      address: 'FRIEND',
      body: 'hey are we still on for dinner tonight',
      dateMillis: ts,
    ));
  }
  return list;
}

void main() {
  test('worker parses bank messages and reports progress + final results',
      () async {
    final controller = SmsScanController();
    final emissions = <ScanProgress>[];
    final sub = controller.progress.listen(emissions.add);

    final results = await controller.run(
      _inbox(bank: 60, junk: 60),
      ScanTrigger.firstLoad,
    );
    await sub.cancel();

    expect(results, isNotNull);
    expect(results!.length, 60); // only the 60 bank messages parse

    // At least one mid-scan emission (every 50) plus the final complete one.
    expect(emissions, isNotEmpty);
    final last = emissions.last;
    expect(last.isComplete, isTrue);
    expect(last.scannedMessages, 120);
    expect(last.bankMessagesFound, 60);

    // Scanned count never decreases.
    for (var i = 1; i < emissions.length; i++) {
      expect(emissions[i].scannedMessages >= emissions[i - 1].scannedMessages,
          isTrue);
    }
  });

  test('cancel before completion yields null (discarded)', () async {
    final controller = SmsScanController();
    // Large inbox so the parse cannot finish synchronously.
    final future = controller.run(
      _inbox(bank: 4000, junk: 4000),
      ScanTrigger.firstLoad,
    );
    controller.cancel();
    final results = await future;
    expect(results, isNull);
  });

  test('empty inbox completes with zero results', () async {
    final controller = SmsScanController();
    final results = await controller.run(const [], ScanTrigger.backgroundRefresh);
    expect(results, isNotNull);
    expect(results, isEmpty);
  });
}
