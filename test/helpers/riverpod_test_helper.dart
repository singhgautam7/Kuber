import 'package:flutter_riverpod/flutter_riverpod.dart';

ProviderContainer createTestContainer({List<Override> overrides = const []}) {
  final container = ProviderContainer(overrides: overrides);
  return container;
}
