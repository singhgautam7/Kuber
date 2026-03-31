import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/tags/data/tag.dart';

void main() {
  group('Tag.normalize', () {
    test('lowercases input', () {
      expect(Tag.normalize('FOOD'), 'food');
    });

    test('replaces spaces with hyphens', () {
      expect(Tag.normalize('eating out'), 'eating-out');
    });

    test('replaces multiple spaces with single hyphen', () {
      expect(Tag.normalize('eating   out'), 'eating-out');
    });

    test('strips special characters', () {
      expect(Tag.normalize('food & drinks!'), 'food--drinks');
    });

    test('keeps digits and underscores', () {
      expect(Tag.normalize('q1_2024'), 'q1_2024');
    });

    test('is idempotent', () {
      const raw = 'My Tag!';
      expect(Tag.normalize(Tag.normalize(raw)), Tag.normalize(raw));
    });

    test('handles empty string', () {
      expect(Tag.normalize(''), '');
    });

    test('handles all special characters', () {
      expect(Tag.normalize('@#\$%^&*()'), '');
    });
  });
}
