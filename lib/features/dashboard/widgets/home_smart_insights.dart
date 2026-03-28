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
  final _scrollController = ScrollController();
  int _currentIndex = 0;
  double _lastCardWidth = 1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    final newIndex = (_scrollController.offset / _lastCardWidth).round();
    if (newIndex != _currentIndex && newIndex >= 0) {
      setState(() => _currentIndex = newIndex);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insights = ref.watch(smartInsightsProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SMART INSIGHTS',
                  style: tt.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                if (insights.isNotEmpty)
                  Text(
                    '${_currentIndex + 1}/${insights.length}',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
              ],
            ),
          ),

          // Horizontal cards
          SizedBox(
            height: 200,
            child: insights.isEmpty
                ? const _InsightsEmptyState()
                : LayoutBuilder(
                    builder: (context, constraints) {
                      final cardWidth = constraints.maxWidth * 0.8;
                      _lastCardWidth = cardWidth + 8; // card + gap for scroll math
                      return ListView.builder(
                        controller: _scrollController,
                        scrollDirection: Axis.horizontal,
                        physics: const PageScrollPhysics(),
                        itemCount: insights.length,
                        itemBuilder: (ctx, i) => SizedBox(
                          width: cardWidth,
                          child: Padding(
                            padding: EdgeInsets.only(
                              right: i == insights.length - 1 ? 0 : 8,
                            ),
                            child: _InsightCard(
                              insight: insights[i],
                              isFirst: i == 0,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final KuberInsight insight;
  final bool isFirst;

  const _InsightCard({required this.insight, required this.isFirst});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final bgColor = isFirst ? cs.primary : cs.surfaceContainer;
    final labelColor =
        isFirst ? Colors.white.withValues(alpha: 0.55) : cs.onSurfaceVariant;
    final iconColor = isFirst
        ? Colors.white.withValues(alpha: 0.85)
        : (insight.iconColor ?? cs.primary);
    final textColor = isFirst ? Colors.white : cs.onSurface;
    final borderColor = isFirst ? Colors.transparent : cs.outline;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type label
          Text(
            insight.typeLabel,
            style: tt.labelSmall?.copyWith(
              color: labelColor,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          // Icon
          if (insight.iconData != null)
            Icon(insight.iconData, color: iconColor, size: 28)
          else
            Text(insight.emoji, style: const TextStyle(fontSize: 24)),
          const Spacer(),
          // Message
          if (isFirst)
            Text(
              insight.message,
              style: tt.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            )
          else
            _HighlightedText(
              message: insight.message,
              highlights: insight.highlights,
              highlightColor:
                  insight.highlightIsWarning ? cs.error : cs.primary,
              baseStyle: tt.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              maxLines: 4,
            ),
        ],
      ),
    );
  }
}

class _InsightsEmptyState extends StatelessWidget {
  const _InsightsEmptyState();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.insights_outlined,
              color: cs.onSurfaceVariant, size: 32),
          const SizedBox(height: 12),
          Text(
            'Keep adding transactions to unlock\ninsights about your finances.',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  final String message;
  final List<String> highlights;
  final Color highlightColor;
  final TextStyle? baseStyle;
  final int maxLines;

  const _HighlightedText({
    required this.message,
    required this.highlights,
    required this.highlightColor,
    this.baseStyle,
    this.maxLines = 4,
  });

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) {
      return Text(message, style: baseStyle, maxLines: maxLines,
          overflow: TextOverflow.ellipsis);
    }

    final spans = <({int start, int end, String text})>[];
    for (final h in highlights) {
      if (h.isEmpty) continue;
      final idx = message.indexOf(h);
      if (idx == -1) continue;
      final end = idx + h.length;
      final overlaps = spans.any((s) => idx < s.end && end > s.start);
      if (!overlaps) {
        spans.add((start: idx, end: end, text: h));
      }
    }

    if (spans.isEmpty) {
      return Text(message, style: baseStyle, maxLines: maxLines,
          overflow: TextOverflow.ellipsis);
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
        style: TextStyle(fontWeight: FontWeight.w700, color: highlightColor),
      ));
      cursor = span.end;
    }
    if (cursor < message.length) {
      children.add(TextSpan(text: message.substring(cursor)));
    }

    return RichText(
      text: TextSpan(style: baseStyle, children: children),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
    );
  }
}
