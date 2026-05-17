import 'package:isar_community/isar.dart';

part 'widget_preference.g.dart';

/// One row per (scope, widgetKey). Together they form the user's widget
/// configuration for a screen.
@collection
class WidgetPreference {
  Id id = Isar.autoIncrement;

  /// 'home' or 'analytics'. String (not enum) so future scopes can be added
  /// without an Isar migration.
  @Index()
  late String scope;

  /// Stable identifier — matches a `case` in the dashboard / analytics
  /// widget builder. Defined in `widget_catalog.dart`.
  late String widgetKey;

  /// Position within the scope. 0-based, ascending.
  late int order;

  late bool enabled;

  Map<String, dynamic> toMap() => {
    'id': id,
    'scope': scope,
    'widgetKey': widgetKey,
    'order': order,
    'enabled': enabled,
  };
}
