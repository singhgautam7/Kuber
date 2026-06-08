/// A functional "how do I..." answer: explanatory [text] plus an optional deep
/// link into the relevant screen.
class HowToResponse {
  final String text;

  /// GoRouter path to navigate to, or null for purely informational topics
  /// (e.g. "is this offline").
  final String? deepLinkRoute;

  /// Chip label shown when [deepLinkRoute] is present, e.g. "Take me there".
  final String? deepLinkLabel;

  const HowToResponse(
    this.text, {
    this.deepLinkRoute,
    this.deepLinkLabel,
  });
}
