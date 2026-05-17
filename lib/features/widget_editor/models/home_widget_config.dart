/// Configuration shown in the widget editor for a single dashboard or
/// analytics widget. The editor only ever sees this — the actual widget
/// implementation is wired up by the screen's switch statement on `id`.
class HomeWidgetConfig {
  final String id;
  final String name;
  final String? description;
  final bool enabled;

  const HomeWidgetConfig({
    required this.id,
    required this.name,
    this.description,
    required this.enabled,
  });

  HomeWidgetConfig copyWith({bool? enabled}) => HomeWidgetConfig(
        id: id,
        name: name,
        description: description,
        enabled: enabled ?? this.enabled,
      );
}

/// Two scopes are supported today: home dashboard and analytics page. Stored
/// as strings in Isar so future scopes don't require a schema migration.
enum WidgetEditorScope { home, analytics }

extension WidgetEditorScopeKey on WidgetEditorScope {
  String get key => switch (this) {
        WidgetEditorScope.home => 'home',
        WidgetEditorScope.analytics => 'analytics',
      };

  String get title => switch (this) {
        WidgetEditorScope.home => 'Edit Home Widgets',
        WidgetEditorScope.analytics => 'Edit Analytics Widgets',
      };
}
