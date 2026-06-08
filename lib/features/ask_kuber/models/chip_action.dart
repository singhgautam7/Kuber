/// A follow-up chip rendered in the strip above the input.
///
/// Two variants:
/// - [AskChipAction]: tapping fills the input and sends [query].
/// - [NavChipAction]: tapping navigates to a GoRouter [route].
///
/// Persisted inside `AskKuberMessage.metadataJson` so a reloaded chat keeps its
/// chips functional.
sealed class ChipAction {
  const ChipAction();

  Map<String, dynamic> toJson();

  static ChipAction fromJson(Map<String, dynamic> json) {
    switch (json['kind'] as String?) {
      case 'nav':
        return NavChipAction(
          label: json['label'] as String? ?? '',
          route: json['route'] as String? ?? '/',
        );
      case 'ask':
      default:
        return AskChipAction(json['query'] as String? ?? '');
    }
  }
}

/// Re-asks Kuber. The chip label is the query itself.
class AskChipAction extends ChipAction {
  final String query;
  const AskChipAction(this.query);

  @override
  Map<String, dynamic> toJson() => {'kind': 'ask', 'query': query};
}

/// Navigates to [route] (a GoRouter path). Filled-pill styling with a trailing
/// arrow; [label] is the visible text (e.g. "Take me there").
class NavChipAction extends ChipAction {
  final String label;
  final String route;
  const NavChipAction({required this.label, required this.route});

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'nav',
    'label': label,
    'route': route,
  };
}
