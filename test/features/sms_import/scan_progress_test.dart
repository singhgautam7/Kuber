import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/sms_import/engine/scan_progress.dart';
import 'package:kuber/features/sms_import/providers/sms_import_provider.dart';

void main() {
  group('ScanProgress', () {
    test('fraction is null until total known, then determinate', () {
      const p0 = ScanProgress(
        totalMessages: 0,
        scannedMessages: 0,
        bankMessagesFound: 0,
        isComplete: false,
        trigger: ScanTrigger.firstLoad,
      );
      expect(p0.fraction, isNull);

      const p1 = ScanProgress(
        totalMessages: 200,
        scannedMessages: 50,
        bankMessagesFound: 3,
        isComplete: false,
        trigger: ScanTrigger.firstLoad,
      );
      expect(p1.fraction, closeTo(0.25, 1e-9));
    });

    test('fraction clamps to 1', () {
      const p = ScanProgress(
        totalMessages: 100,
        scannedMessages: 100,
        bankMessagesFound: 5,
        isComplete: true,
        trigger: ScanTrigger.backgroundRefresh,
      );
      expect(p.fraction, 1.0);
    });
  });

  group('SmsImportState', () {
    test('isScanning reflects an in-flight (incomplete) progress', () {
      const running = ScanProgress(
        totalMessages: 10,
        scannedMessages: 2,
        bankMessagesFound: 0,
        isComplete: false,
        trigger: ScanTrigger.backgroundRefresh,
      );
      final s = const SmsImportState().copyWith(scanProgress: running);
      expect(s.isScanning, isTrue);

      final done = s.copyWith(
        scanProgress: const ScanProgress(
          totalMessages: 10,
          scannedMessages: 10,
          bankMessagesFound: 1,
          isComplete: true,
          trigger: ScanTrigger.backgroundRefresh,
        ),
      );
      expect(done.isScanning, isFalse);
    });

    test('copyWith can clear scanProgress back to null', () {
      final s = const SmsImportState().copyWith(
        scanProgress: const ScanProgress(
          totalMessages: 1,
          scannedMessages: 1,
          bankMessagesFound: 0,
          isComplete: true,
          trigger: ScanTrigger.backgroundRefresh,
        ),
      );
      expect(s.scanProgress, isNotNull);
      final cleared = s.copyWith(scanProgress: null);
      expect(cleared.scanProgress, isNull);
    });

    test('copyWith preserves list identity when not changed', () {
      final base = SmsImportState(unreviewed: List.unmodifiable([]));
      final next = base.copyWith(
        scanProgress: const ScanProgress(
          totalMessages: 5,
          scannedMessages: 1,
          bankMessagesFound: 0,
          isComplete: false,
          trigger: ScanTrigger.backgroundRefresh,
        ),
      );
      // Same list instance -> select() on the list short-circuits, so the list
      // UI does not rebuild during scan progress updates.
      expect(identical(base.unreviewed, next.unreviewed), isTrue);
    });
  });
}
