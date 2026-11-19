import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kuber/core/motion/motion.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final calls = <String>[];
  var clock = DateTime(2026);

  setUp(() {
    calls.clear();
    clock = DateTime(2026);
    KuberHaptics.enabled = true;
    KuberHaptics.scrolling = false;
    KuberHaptics.now = () => clock;
    KuberHaptics.reset();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (c) async {
      if (c.method == 'HapticFeedback.vibrate') calls.add(c.arguments as String);
      return null;
    });
  });
  tearDown(() {
    KuberHaptics.enabled = false;
    KuberHaptics.now = DateTime.now;
  });

  test('maps each haptic to its Flutter call', () {
    KuberHaptics.tick();
    clock = clock.add(const Duration(milliseconds: 60));
    KuberHaptics.longPress();
    clock = clock.add(const Duration(milliseconds: 60));
    KuberHaptics.threshold();
    clock = clock.add(const Duration(milliseconds: 60));
    KuberHaptics.confirm();
    clock = clock.add(const Duration(milliseconds: 60));
    KuberHaptics.reject();
    expect(calls, [
      'HapticFeedbackType.selectionClick',
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.mediumImpact',
      'HapticFeedbackType.lightImpact',
      'HapticFeedbackType.heavyImpact',
    ]);
  });

  test('two calls within 50 ms play once; after 50 ms again', () {
    KuberHaptics.tick();
    clock = clock.add(const Duration(milliseconds: 49));
    KuberHaptics.tick();
    expect(calls.length, 1);
    clock = clock.add(const Duration(milliseconds: 2));
    KuberHaptics.tick();
    expect(calls.length, 2);
  });

  test('the switch off means silence', () {
    KuberHaptics.enabled = false;
    KuberHaptics.tick();
    KuberHaptics.reject();
    expect(calls, isEmpty);
  });

  test('none while scrolling, and a blocked call does not eat the window', () {
    KuberHaptics.scrolling = true;
    KuberHaptics.tick();
    expect(calls, isEmpty);
    KuberHaptics.scrolling = false;
    KuberHaptics.tick();
    expect(calls.length, 1);
  });
}
