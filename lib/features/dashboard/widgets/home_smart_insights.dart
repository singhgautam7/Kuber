import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../insights/models/insight.dart';
import '../../insights/providers/insight_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../shared/widgets/kuber_home_widget_title.dart';

class HomeSmartInsights extends ConsumerStatefulWidget {
  const HomeSmartInsights({super.key});

  @override
  ConsumerState<HomeSmartInsights> createState() => _HomeSmartInsightsState();
}

class _HomeSmartInsightsState extends ConsumerState<HomeSmartInsights> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insights = ref.watch(smartInsightsProvider);
    final isPrivate = ref.watch(privacyModeProvider);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          KuberHomeWidgetTitle(title: context.l10n.smartInsights),

          SizedBox(
            height: 144,
            child: insights.isEmpty
                ? const _InsightsEmptyState()
                : PageView.builder(
                    controller: _pageController,
                    padEnds: false, // Keeps the first card left-aligned
                    onPageChanged: (index) {
                      setState(() => _currentIndex = index);
                    },
                    itemCount: insights.length,
                    itemBuilder: (ctx, i) => Padding(
                      padding: const EdgeInsets.only(right: KuberSpace.cardGap),
                      child: _InsightCard(
                        insight: insights[i],
                        isFirst: i == 0,
                        isPrivate: isPrivate,
                      ),
                    ),
                  ),
          ),
          // Page dots (board 3.2a) instead of the "1/n" counter.
          if (insights.length > 1) ...[
            const SizedBox(height: KuberSpace.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6,
              children: [
                for (var i = 0; i < insights.length; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: i == _currentIndex ? 16 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: i == _currentIndex
                          ? cs.primary
                          : cs.outlineVariant,
                      borderRadius: KuberShape.fullR,
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  final KuberInsight insight;
  final bool isFirst;
  final bool isPrivate;

  const _InsightCard({
    required this.insight,
    required this.isFirst,
    required this.isPrivate,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;

    // Carousel card (board 3.2a): 40 tile in the insight's container role,
    // titleSmall type label, bodyMedium message with highlights.
    final tone = switch (insight.iconAccent) {
      InsightAccent.income => KuberTone.income,
      InsightAccent.expense => KuberTone.expense,
      InsightAccent.warning => KuberTone.warning,
      InsightAccent.purple ||
      InsightAccent.primary ||
      null => KuberTone.secondary,
    };
    final (tileBg, tileFg) = kuberToneColors(context, tone);
    final message = isPrivate
        ? insight.highlights.fold<String>(
            insight.message,
            (msg, h) => msg.replaceAll(h, '****'),
          )
        : insight.message;

    return KuberCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tileBg,
              borderRadius: KuberShape.mediumR,
            ),
            alignment: Alignment.center,
            child: insight.iconData != null
                ? Icon(insight.iconData, color: tileFg, size: 20)
                : Text(insight.emoji, style: const TextStyle(fontSize: 18)),
          ),
          const SizedBox(width: KuberSpace.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sentenceCase(insight.typeLabel),
                  style: tt.titleMedium?.copyWith(color: cs.onSurface),
                ),
                const SizedBox(height: 2),
                _HighlightedText(
                  message: message,
                  highlights: isPrivate ? const [] : insight.highlights,
                  highlightColor: insight.highlightIsWarning
                      ? context.kuberMoney.expense
                      : cs.primary,
                  baseStyle: tt.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                  maxLines: 4,
                ),
              ],
            ),
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
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    return KuberCard(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.insights_outlined, color: cs.onSurfaceVariant, size: 24),
            const SizedBox(height: KuberSpace.sm),
            Text(
              context.l10n.smartInsightsEmpty,
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
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
      return Text(
        message,
        style: baseStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
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
      return Text(
        message,
        style: baseStyle,
        maxLines: maxLines,
        overflow: TextOverflow.ellipsis,
      );
    }

    spans.sort((a, b) => a.start.compareTo(b.start));

    final children = <TextSpan>[];
    int cursor = 0;
    for (final span in spans) {
      if (span.start > cursor) {
        children.add(TextSpan(text: message.substring(cursor, span.start)));
      }
      children.add(
        TextSpan(
          text: span.text,
          style: TextStyle(fontWeight: FontWeight.w700, color: highlightColor),
        ),
      );
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
