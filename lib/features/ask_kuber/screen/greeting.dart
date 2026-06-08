import 'dart:math';

/// A Welcome-state greeting opener. [eveningOnly] entries are only eligible from
/// 17:00 onward.
class _Greeting {
  final String text;
  final bool eveningOnly;
  const _Greeting(this.text, {this.eveningOnly = false});
}

const _welcomeGreetings = [
  _Greeting('Hi'),
  _Greeting('Hello'),
  _Greeting('Hey'),
  _Greeting('Namaste'),
  _Greeting('Welcome back'),
  _Greeting('Ssup', eveningOnly: true),
];

/// SharedPreferences key holding the last greeting word shown, so the next
/// Welcome render can avoid repeating it.
const lastAskKuberGreetingKey = 'last_ask_kuber_greeting';

/// Picks a greeting word for the current [hour], filtered so evening-only
/// openers appear only from 17:00, excluding [lastUsed] unless that would empty
/// the pool. Pure (inject [random] in tests).
String selectGreetingWord(int hour, String? lastUsed, {Random? random}) {
  final rng = random ?? Random();
  var pool = _welcomeGreetings
      .where((g) => !g.eveningOnly || hour >= 17)
      .map((g) => g.text)
      .toList();
  final withoutLast = pool.where((w) => w != lastUsed).toList();
  if (withoutLast.isNotEmpty) pool = withoutLast;
  return pool[rng.nextInt(pool.length)];
}

/// Composes the compact greeting line: "{word}, {name}." or, when the name is
/// empty, "{word}." The trailing period is part of the copy.
String composeCompactGreeting(String word, String rawName) {
  final name = rawName.trim();
  return name.isEmpty ? '$word.' : '$word, $name.';
}
