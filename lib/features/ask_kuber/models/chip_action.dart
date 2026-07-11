/// A follow-up chip rendered in the strip above the input.
///
/// Three variants:
/// - [AskChipAction]: tapping fills the input and sends [query].
/// - [NavChipAction]: tapping navigates to a GoRouter [route].
/// - [EmailChipAction]: tapping opens the mail client to the developer with a
///   pre-filled subject/body (used by the knowledge handler).
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
      case 'email':
        return EmailChipAction(
          label: json['label'] as String? ?? 'Email the developer',
          subject: json['subject'] as String? ?? '',
          body: json['body'] as String? ?? '',
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

/// Opens the mail client to the developer with a pre-filled [subject] and
/// [body]. Filled-pill styling with a leading envelope icon. [body] may contain
/// `{version}` / `{device}` placeholders, resolved at launch time.
class EmailChipAction extends ChipAction {
  final String label;
  final String subject;
  final String body;
  const EmailChipAction({
    required this.label,
    required this.subject,
    required this.body,
  });

  @override
  Map<String, dynamic> toJson() => {
    'kind': 'email',
    'label': label,
    'subject': subject,
    'body': body,
  };
}
