import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/isar_service.dart';
import '../data/widget_preference_repository.dart';
import '../models/home_widget_config.dart';

final widgetPreferenceRepositoryProvider =
    Provider<WidgetPreferenceRepository>((ref) {
  return WidgetPreferenceRepository(ref.watch(isarProvider));
});

/// Ordered widget list for the home dashboard. The dashboard's builder
/// walks this list and skips disabled entries — disabled widgets are never
/// constructed, so their providers never run.
final homeWidgetsProvider =
    FutureProvider<List<HomeWidgetConfig>>((ref) async {
  final repo = ref.watch(widgetPreferenceRepositoryProvider);
  return repo.readForScope(WidgetEditorScope.home);
});

final analyticsWidgetsProvider =
    FutureProvider<List<HomeWidgetConfig>>((ref) async {
  final repo = ref.watch(widgetPreferenceRepositoryProvider);
  return repo.readForScope(WidgetEditorScope.analytics);
});

/// Saves new configs and invalidates the matching read provider so the
/// dashboard / analytics screen rebuilds with the updated order. Accepts
/// either [Ref] or [WidgetRef] since both expose `read` and `invalidate`.
Future<void> saveWidgetPreferences(
  WidgetRef ref,
  WidgetEditorScope scope,
  List<HomeWidgetConfig> configs,
) async {
  await ref.read(widgetPreferenceRepositoryProvider).save(scope, configs);
  switch (scope) {
    case WidgetEditorScope.home:
      ref.invalidate(homeWidgetsProvider);
      break;
    case WidgetEditorScope.analytics:
      ref.invalidate(analyticsWidgetsProvider);
      break;
  }
}
