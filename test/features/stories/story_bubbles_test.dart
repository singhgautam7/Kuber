import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/stories/models/story_models.dart';
import 'package:kuber/features/stories/providers/story_providers.dart';

StoryViewData _story({
  required int id,
  required String type,
  required DateTime generatedAt,
  bool seen = false,
}) {
  const slide = StorySlide(
    variant: SlideVariant.statement,
    background: StoryColorKey.blue,
    icon: 'calendar',
    title: 'x',
  );
  return StoryViewData(
    id: id,
    storyKey: 'k$id',
    type: type,
    label: type,
    icon: 'calendar',
    color: StoryColorKey.blue,
    timeLabel: '',
    generatedAt: generatedAt,
    expiresAt: generatedAt.add(const Duration(hours: 48)),
    seenAt: seen ? generatedAt : null,
    seenSlides: seen ? [0] : [],
    slides: const [slide],
  );
}

void main() {
  group('groupIntoBubbles', () {
    test('produces one bubble per type, holding all that type stories', () {
      final bubbles = groupIntoBubbles([
        _story(id: 1, type: 'insights', generatedAt: DateTime(2026, 6, 1)),
        _story(id: 2, type: 'recap_day', generatedAt: DateTime(2026, 6, 2)),
        _story(id: 3, type: 'recap_day', generatedAt: DateTime(2026, 6, 3)),
        _story(id: 4, type: 'recap_week', generatedAt: DateTime(2026, 6, 1)),
        _story(id: 5, type: 'welcome', generatedAt: DateTime(2026, 6, 1)),
      ]);

      expect(bubbles.length, 4);
      expect(
        bubbles.map((b) => b.type).toSet(),
        {'welcome', 'recap_day', 'recap_week', 'insights'},
      );
      expect(
        bubbles.firstWhere((b) => b.type == 'recap_day').stories.length,
        2,
      );
    });

    test('orders bubbles unread-first, then by most recent generation', () {
      final bubbles = groupIntoBubbles([
        // Seen but newest — must still come after any unread bubble.
        _story(id: 1, type: 'recap_day', generatedAt: DateTime(2026, 6, 5), seen: true),
        // Unread, older.
        _story(id: 2, type: 'recap_week', generatedAt: DateTime(2026, 6, 1)),
        // Unread, newer.
        _story(id: 3, type: 'recap_month', generatedAt: DateTime(2026, 6, 3)),
      ]);

      expect(
        bubbles.map((b) => b.type).toList(),
        ['recap_month', 'recap_week', 'recap_day'],
      );
    });

    test('keeps stories in stable chronological order (oldest first)', () {
      final bubbles = groupIntoBubbles([
        _story(id: 3, type: 'recap_day', generatedAt: DateTime(2026, 6, 5), seen: true),
        _story(id: 1, type: 'recap_day', generatedAt: DateTime(2026, 6, 1), seen: true),
        _story(id: 2, type: 'recap_day', generatedAt: DateTime(2026, 6, 3)),
      ]);

      // Order does not shuffle by read state — the viewer opens the first unread.
      final ids = bubbles.single.stories.map((s) => s.id).toList();
      expect(ids, [1, 2, 3]);
    });

    test('first-unread story in a bubble is the one the viewer opens', () {
      // 5 stories, first 2 read -> the viewer should open the third.
      final bubble = groupIntoBubbles([
        _story(id: 1, type: 'insights', generatedAt: DateTime(2026, 6, 1), seen: true),
        _story(id: 2, type: 'insights', generatedAt: DateTime(2026, 6, 2), seen: true),
        _story(id: 3, type: 'insights', generatedAt: DateTime(2026, 6, 3)),
        _story(id: 4, type: 'insights', generatedAt: DateTime(2026, 6, 4)),
        _story(id: 5, type: 'insights', generatedAt: DateTime(2026, 6, 5)),
      ]).single;

      final firstUnread = bubble.stories.indexWhere((s) => !s.seen);
      expect(firstUnread, 2); // the third story
    });

    test('a bubble is seen only when all its stories are seen', () {
      final mixed = groupIntoBubbles([
        _story(id: 1, type: 'loans', generatedAt: DateTime(2026, 6, 1), seen: true),
        _story(id: 2, type: 'loans', generatedAt: DateTime(2026, 6, 2)),
      ]).single;
      expect(mixed.seen, isFalse);

      final allSeen = groupIntoBubbles([
        _story(id: 1, type: 'loans', generatedAt: DateTime(2026, 6, 1), seen: true),
        _story(id: 2, type: 'loans', generatedAt: DateTime(2026, 6, 2), seen: true),
      ]).single;
      expect(allSeen.seen, isTrue);
    });
  });
}
