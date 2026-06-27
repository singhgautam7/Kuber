import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../models/chat_message.dart';
import '../models/viz_payload.dart';
import 'budget_status_viz.dart';
import 'thinking_panel.dart';
import 'top_categories_viz.dart';

/// Dispatches to the user or Kuber message. No avatar on either side. When
/// [stream] is supplied (the actively-typing Kuber message), the text is read
/// from it and a blinking caret is shown; meta/viz/thinking are withheld until
/// streaming completes.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final ValueListenable<String>? stream;

  const MessageBubble({super.key, required this.message, this.stream});

  @override
  Widget build(BuildContext context) {
    return message.isUser
        ? _UserBubble(message: message)
        : _KuberMessage(message: message, stream: stream);
  }
}



class _UserBubble extends StatelessWidget {
  final ChatMessage message;
  const _UserBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.78),
        child: Container(
          margin: const EdgeInsets.only(bottom: KuberSpacing.md),
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 7),
          decoration: BoxDecoration(
            // Primary-tinted fill with a subtle primary border (per design CSS).
            color: cs.primary.withValues(alpha: 0.10),
            border: Border.all(color: cs.primary.withValues(alpha: 0.22)),
            borderRadius: BorderRadius.circular(KuberRadius.lg),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.text,
                  style: localeFont(
                      fontSize: 14, color: cs.onSurface, height: 1.45)),
              const SizedBox(height: 3),
              Text(
                DateFormat('h:mm a').format(message.time),
                style: localeFont(
                    fontSize: 10, color: cs.onSurfaceVariant.withValues(alpha: 0.85)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Currency/number highlight spans for Kuber text.
List<InlineSpan> buildRichSpans(String text, TextStyle base, Color highlight) {
  final pattern = RegExp(r'[₹$€£]?[\d,]+(?:\.\d+)?', caseSensitive: false);
  final spans = <InlineSpan>[];
  int last = 0;
  for (final m in pattern.allMatches(text)) {
    final matched = m.group(0)!;
    if (!RegExp(r'\d').hasMatch(matched)) continue;
    if (m.start > last) {
      spans.add(TextSpan(text: text.substring(last, m.start), style: base));
    }
    spans.add(TextSpan(
        text: matched,
        style: base.copyWith(fontWeight: FontWeight.w600, color: highlight)));
    last = m.end;
  }
  if (last < text.length) {
    spans.add(TextSpan(text: text.substring(last), style: base));
  }
  return spans;
}

/// Kuber message: bare editorial text on the chat surface, no bubble box.
class _KuberMessage extends StatefulWidget {
  final ChatMessage message;
  final ValueListenable<String>? stream;
  const _KuberMessage({required this.message, this.stream});

  @override
  State<_KuberMessage> createState() => _KuberMessageState();
}

class _KuberMessageState extends State<_KuberMessage>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _sizeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200));
    _sizeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    _expanded ? _ctrl.forward() : _ctrl.reverse();
  }

  TextStyle get _textStyle =>
      localeFont(fontSize: 15, color: Theme.of(context).colorScheme.onSurface, height: 1.5);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final msg = widget.message;
    final maxW = MediaQuery.sizeOf(context).width * 0.86;

    // Streaming: bare growing text + blinking caret, nothing else yet.
    if (widget.stream != null) {
      return Align(
        alignment: Alignment.centerLeft,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxW),
          child: Padding(
            padding: const EdgeInsets.only(bottom: KuberSpacing.md),
            child: ValueListenableBuilder<String>(
              valueListenable: widget.stream!,
              builder: (context, text, _) => Text.rich(
                TextSpan(children: [
                  ...buildRichSpans(text, _textStyle, cs.primary),
                  WidgetSpan(
                    alignment: PlaceholderAlignment.middle,
                    child: RepaintBoundary(child: BlinkingCaret(color: cs.primary)),
                  ),
                ]),
              ),
            ),
          ),
        ),
      );
    }

    final thinking = msg.thinking;
    final viz = msg.vizPayload;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Padding(
          padding: const EdgeInsets.only(bottom: KuberSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text.rich(TextSpan(
                  children: buildRichSpans(msg.text, _textStyle, cs.primary))),
              if (viz != null) ...[
                const SizedBox(height: KuberSpacing.sm),
                _buildViz(viz),
              ],
              if (thinking != null)
                ThinkingMetaRow(
                  time: DateFormat('h:mm a').format(msg.time),
                  expanded: _expanded,
                  onToggle: _toggle,
                ),
              if (thinking == null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(DateFormat('h:mm a').format(msg.time),
                      style:
                          localeFont(fontSize: 11, color: cs.onSurfaceVariant)),
                ),
              if (thinking != null)
                SizeTransition(
                  sizeFactor: _sizeAnim,
                  axisAlignment: -1,
                  child: ThinkingPanel(thinking: thinking),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViz(VizPayload viz) => switch (viz) {
        TopCategoriesViz() => TopCategoriesVizView(data: viz),
        BudgetStatusViz() => BudgetStatusVizView(data: viz),
      };
}
