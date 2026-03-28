import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../insights/models/insight.dart';
import '../../insights/providers/insight_provider.dart';

class HomeSmartInsights extends ConsumerStatefulWidget {
  const HomeSmartInsights({super.key});

  @override
  ConsumerState<HomeSmartInsights> createState() => _HomeSmartInsightsState();
}

class _HomeSmartInsightsState extends ConsumerState<HomeSmartInsights> {
  bool _showAllInsights = false;

  @override
  Widget build(BuildContext context) {
    final insights = ref.watch(smartInsightsProvider);
    final textTheme = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    if (insights.isEmpty) return const SizedBox.shrink();

    final visible = _showAllInsights ? insights : insights.take(3).toList();
    final hasMore = insights.length > 3;

    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SMART INSIGHTS',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                if (hasMore)
                  GestureDetector(
                    onTap: () =>
                        setState(() => _showAllInsights = !_showAllInsights),
                    child: Text(
                      _showAllInsights ? 'SHOW LESS' : 'VIEW ALL',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.0,
                        color: cs.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: cs.outline),
            ),
            child: Column(
              children: [
                for (int i = 0; i < visible.length; i++) ...[
                  _InsightTile(insight: visible[i]),
                  if (i < visible.length - 1)
                    Container(height: 1, color: cs.outline),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InsightTile extends StatelessWidget {
  final KuberInsight insight;
  const _InsightTile({required this.insight});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          _buildIconContainer(cs),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (insight.typeLabel.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      insight.typeLabel,
                      style: textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                _HighlightedText(
                  message: insight.message,
                  highlights: insight.highlights,
                  highlightColor: insight.highlightIsWarning
                      ? cs.error
                      : cs.primary,
                  baseStyle: textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIconContainer(ColorScheme cs) {
    if (insight.iconData != null) {
      final color = insight.iconColor ?? cs.primary;
      return Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(insight.iconData, color: color, size: 22),
      );
    }

    // Fallback to emoji
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          insight.emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String message;
  final List<String> highlights;
  final Color highlightColor;
  final TextStyle? baseStyle;

  const _HighlightedText({
    required this.message,
    required this.highlights,
    required this.highlightColor,
    this.baseStyle,
  });

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) {
      return Text(message, style: baseStyle);
    }

    // Find all highlight positions, sorted by index, no overlaps
    final spans = <({int start, int end, String text})>[];
    for (final h in highlights) {
      if (h.isEmpty) continue;
      final idx = message.indexOf(h);
      if (idx == -1) continue;
      // Check for overlap with existing spans
      final end = idx + h.length;
      final overlaps = spans.any(
        (s) => idx < s.end && end > s.start,
      );
      if (!overlaps) {
        spans.add((start: idx, end: end, text: h));
      }
    }

    if (spans.isEmpty) {
      return Text(message, style: baseStyle);
    }

    spans.sort((a, b) => a.start.compareTo(b.start));

    final children = <TextSpan>[];
    int cursor = 0;
    for (final span in spans) {
      if (span.start > cursor) {
        children.add(TextSpan(text: message.substring(cursor, span.start)));
      }
      children.add(TextSpan(
        text: span.text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: highlightColor,
        ),
      ));
      cursor = span.end;
    }
    if (cursor < message.length) {
      children.add(TextSpan(text: message.substring(cursor)));
    }

    return RichText(
      text: TextSpan(style: baseStyle, children: children),
    );
  }
}
