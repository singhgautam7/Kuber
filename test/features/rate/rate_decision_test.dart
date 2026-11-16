import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/features/rate/rate_decision.dart';

bool ask(int n,
        {bool never = false,
        bool tapped = false,
        bool welcome = false,
        bool external = false,
        bool onTop = false}) =>
    shouldShowRatePrompt(
      launchCount: n,
      neverShow: never,
      rateTapped: tapped,
      inWelcomeFlow: welcome,
      openedExternally: external,
      somethingOnTop: onTop,
    );

void main() {
  test('launches 1 to 20: shows exactly on 2, 4, 8 and 16', () {
    final shown = [for (var n = 1; n <= 20; n++) if (ask(n)) n];
    expect(shown, [2, 4, 8, 16]);
  });

  test('never after 16', () => expect(ask(32), isFalse));

  for (final (name, args) in <(String, Map<String, bool>)>[
    ('don\'t show again', {'never': true}),
    ('rate tapped', {'tapped': true}),
    ('welcome flow', {'welcome': true}),
    ('opened from a widget or notification', {'external': true}),
    ('something on top', {'onTop': true}),
  ]) {
    test('$name blocks every scheduled launch', () {
      for (final n in rateLaunches) {
        expect(
          ask(n,
              never: args['never'] ?? false,
              tapped: args['tapped'] ?? false,
              welcome: args['welcome'] ?? false,
              external: args['external'] ?? false,
              onTop: args['onTop'] ?? false),
          isFalse,
        );
      }
    });
  }
}
