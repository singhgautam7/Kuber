/// Time-of-day greeting for the Welcome state. Pure so it can be unit tested.
///
/// Buckets: 05:00-11:59 morning, 12:00-16:59 afternoon, 17:00-21:59 evening,
/// 22:00-04:59 "Hi". The trailing period is part of the copy. When [rawName] is
/// empty the name and comma are dropped but the period stays ("Good morning.").
String composeAskGreeting(String rawName, int hour) {
  final name = rawName.trim();
  final String prefix;
  if (hour >= 5 && hour < 12) {
    prefix = 'Good morning';
  } else if (hour >= 12 && hour < 17) {
    prefix = 'Good afternoon';
  } else if (hour >= 17 && hour < 22) {
    prefix = 'Good evening';
  } else {
    prefix = 'Hi';
  }
  return name.isEmpty ? '$prefix.' : '$prefix, $name.';
}
