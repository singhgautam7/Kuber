import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../models/chat_message.dart';
import '../models/viz_payload.dart';
import 'budget_status_viz.dart';
import 'top_categories_viz.dart';

/// Dispatches to the user or Kuber bubble. No avatar on either side - Kuber's
/// identity lives in the AppBar mark.
class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return message.isUser
        ? _UserBubble(message: message)
        : _KuberBubble(message: message);
  }
}

/// Day divider inserted above the first message of each calendar day.
class DateSeparator extends StatelessWidget {
  final DateTime date;
  const DateSeparator({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final d = DateTime(date.year, date.month, date.day);

    final String label;
    if (d == today) {
      label = 'Today';
    } else if (d == yesterday) {
      label = 'Yesterday';
    } else {
      label = DateFormat('d MMM yyyy').format(date);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: KuberSpacing.md),
      child: Row(children: [
        Expanded(child: Divider(color: cs.outline.withValues(alpha: 0.3))),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.md),
          child: Text(
            label,
            style: localeFont(
                fontSize: 11,
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(child: Divider(color: cs.outline.withValues(alpha: 0.3))),
      ]),
    );
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
            BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.75),
        child: Container(
          margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
          padding: const EdgeInsets.symmetric(
              horizontal: KuberSpacing.md, vertical: KuberSpacing.sm),
          decoration: BoxDecoration(
            color: cs.primary,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              topRight: Radius.circular(4),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: localeFont(fontSize: 14, color: cs.onPrimary),
              ),
              const SizedBox(height: 3),
              Text(
                DateFormat('h:mm a').format(message.time),
                style: localeFont(
                    fontSize: 10, color: cs.onPrimary.withValues(alpha: 0.7)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Builds a [TextSpan] that highlights currency/number tokens in [highlight].
TextSpan buildRichText(String text, TextStyle base, Color highlight) {
  final pattern = RegExp(r'[₹$€£]?[\d,]+(?:\.\d+)?', caseSensitive: false);
  final spans = <TextSpan>[];
  int last = 0;
  for (final m in pattern.allMatches(text)) {
    final matched = m.group(0)!;
    if (!RegExp(r'\d').hasMatch(matched)) continue;
    if (m.start > last) {
      spans.add(TextSpan(text: text.substring(last, m.start), style: base));
    }
    spans.add(TextSpan(
      text: matched,
      style: base.copyWith(fontWeight: FontWeight.w700, color: highlight),
    ));
    last = m.end;
  }
  if (last < text.length) {
    spans.add(TextSpan(text: text.substring(last), style: base));
  }
  return TextSpan(children: spans);
}

class _KuberBubble extends StatefulWidget {
  final ChatMessage message;
  const _KuberBubble({required this.message});

  @override
  State<_KuberBubble> createState() => _KuberBubbleState();
}

class _KuberBubbleState extends State<_KuberBubble>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;
  late final AnimationController _ctrl;
  late final Animation<double> _sizeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final msg = widget.message;
    final thinking = msg.thinking;
    final viz = msg.vizPayload;
    final maxW = MediaQuery.sizeOf(context).width * 0.82;

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxW),
        child: Container(
          // Full width when a visualization is present so its bars have room.
          width: viz != null ? maxW : null,
          margin: const EdgeInsets.only(bottom: KuberSpacing.sm),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(16),
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),
            border: Border.all(color: cs.outline.withValues(alpha: 0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: KuberSpacing.md, vertical: KuberSpacing.sm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: buildRichText(
                        msg.text,
                        localeFont(fontSize: 14, color: cs.onSurface),
                        cs.primary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      DateFormat('h:mm a').format(msg.time),
                      style:
                          localeFont(fontSize: 10, color: cs.onSurfaceVariant),
                    ),
                    if (viz != null) ...[
                      const SizedBox(height: KuberSpacing.sm),
                      _buildViz(viz),
                    ],
                  ],
                ),
              ),
              if (thinking != null) ...[
                Divider(height: 1, color: cs.outline.withValues(alpha: 0.2)),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _toggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.md, vertical: 6),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AnimatedRotation(
                          turns: _expanded ? 0.25 : 0,
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          child: Icon(Icons.chevron_right_rounded,
                              size: 14, color: cs.onSurfaceVariant),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'SHOW THINKING',
                          style: localeFont(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.8,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizeTransition(
                  sizeFactor: _sizeAnim,
                  axisAlignment: -1,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(KuberSpacing.md, 0,
                        KuberSpacing.md, KuberSpacing.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Divider(
                            height: 1,
                            color: cs.outline.withValues(alpha: 0.15)),
                        const SizedBox(height: 6),
                        _ThinkingRow(
                            label: 'Date filter',
                            value: thinking.dateFilter,
                            cs: cs),
                        if (thinking.scanned.isNotEmpty)
                          _ThinkingRow(
                              label: 'Scanned',
                              value: thinking.scanned.join(', '),
                              cs: cs),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildViz(VizPayload viz) {
    return switch (viz) {
      TopCategoriesViz() => TopCategoriesVizView(data: viz),
      BudgetStatusViz() => BudgetStatusVizView(data: viz),
    };
  }
}

class _ThinkingRow extends StatelessWidget {
  final String label;
  final String value;
  final ColorScheme cs;
  const _ThinkingRow(
      {required this.label, required this.value, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: RichText(
        text: TextSpan(
          style: localeFont(fontSize: 11, color: cs.onSurfaceVariant),
          children: [
            TextSpan(
                text: '$label: ',
                style: const TextStyle(fontWeight: FontWeight.w600)),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}
