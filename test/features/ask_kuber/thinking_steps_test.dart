import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/ask_kuber/handlers/thinking_steps.dart';
import 'package:kuber/features/ask_kuber/models/thinking_info.dart';

void main() {
  group('step builders', () {
    test('intent step embeds intent + range as bold tokens', () {
      final s = intentStep('top expense category', 'this month');
      expect(s.text,
          'Detected intent: **top expense category**. Parsed time range: **this month**.');
    });

    test('scanned step drops the grouping clause when no groups', () {
      expect(scannedStep(87, 'transactions').text, 'Scanned **87 transactions**.');
    });

    test('scanned step adds grouping clause and singularizes', () {
      expect(
        scannedStep(87, 'transactions',
                groups: 12, groupType: 'categories', dimension: 'category')
            .text,
        'Scanned **87 transactions** across **12 categories**, grouped by category.',
      );
      expect(scannedStep(1, 'transactions').text, 'Scanned **1 transaction**.');
    });
  });

  group('ThinkingInfo serialization', () {
    test('steps round-trip through JSON', () {
      const info = ThinkingInfo(
        dateFilter: 'All time',
        scanned: ['Transactions'],
        steps: [ThinkingStep('Detected intent: **x**.'), ThinkingStep('done')],
      );
      final restored = ThinkingInfo.fromJson(info.toJson());
      expect(restored.steps.map((s) => s.text).toList(),
          ['Detected intent: **x**.', 'done']);
      expect(restored.dateFilter, 'All time');
    });

    test('old payload without a steps key deserializes to empty steps', () {
      final restored = ThinkingInfo.fromJson({
        'dateFilter': 'this month',
        'scanned': ['Transactions'],
      });
      expect(restored.steps, isEmpty);
      expect(restored.dateFilter, 'this month');
    });
  });
}
