import 'package:flutter/material.dart';
import '../../../core/theme/app_text_styles.dart';

import '../../../core/theme/app_theme.dart';
import '../models/story_icons.dart';
import '../models/story_models.dart';

class StorySlideView extends StatelessWidget {
  final StorySlide slide;
  const StorySlideView({super.key, required this.slide});

  static const _fg = Colors.white;
  static final _muted = Colors.white.withValues(alpha: 0.62);
  static final _subtle = Colors.white.withValues(alpha: 0.86);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: StoryPalette.background[slide.background]!,
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.34),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.40),
                ],
                stops: [0, 0.26, 0.64, 1],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(26, 64, 26, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _iconChip(),
                const SizedBox(height: 22),
                if (slide.header != null) ...[
                  Text(
                    slide.header!.toUpperCase(),
                    style: AppTextStyles.inter.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2,
                      color: _muted,
                    ),
                  ),
                  if (slide.dateLabel != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      slide.dateLabel!,
                      style: AppTextStyles.inter.copyWith(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w500,
                        color: Colors.white.withValues(alpha: 0.55),
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                  const SizedBox(height: 14),
                ],
                Expanded(child: _body()),
                if (slide.footer != null) ...[
                  const SizedBox(height: 24),
                  Text(
                    slide.footer!,
                    style: AppTextStyles.inter.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: _muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _iconChip() => Container(
    width: 46,
    height: 46,
    decoration: BoxDecoration(
      color: Colors.white.withValues(alpha: 0.16),
      borderRadius: BorderRadius.circular(KuberRadius.md),
    ),
    alignment: Alignment.center,
    child: Icon(storyIcon(slide.icon), size: 26, color: Colors.white),
  );

  Widget _body() {
    return switch (slide.variant) {
      SlideVariant.hero => _hero(),
      SlideVariant.stats => _stats(),
      SlideVariant.compare => _compare(),
      SlideVariant.statement => _statement(),
    };
  }

  Widget _hero() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      if (slide.hero != null)
        Text(
          slide.hero!,
          style: AppTextStyles.inter.copyWith(
            fontSize: 62,
            fontWeight: FontWeight.w800,
            height: 1,
            color: _fg,
          ),
        ),
      const SizedBox(height: 10),
      _emphasised(
        slide.title,
        base: AppTextStyles.inter.copyWith(
          fontSize: 26,
          fontWeight: FontWeight.w800,
          height: 1.1,
          color: _fg,
        ),
      ),
      if (slide.subtitle != null) ...[
        const SizedBox(height: 16),
        _emphasised(
          slide.subtitle!,
          base: AppTextStyles.inter.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            height: 1.45,
            color: _subtle,
          ),
        ),
      ],
    ],
  );

  Widget _stats() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _emphasised(
        slide.title,
        base: AppTextStyles.inter.copyWith(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          height: 1.1,
          color: _fg,
        ),
      ),
      const SizedBox(height: 18),
      for (int i = 0; i < slide.stats.length; i++) ...[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 7),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  slide.stats[i].label,
                  style: AppTextStyles.inter.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: _subtle,
                  ),
                ),
              ),
              Text(
                slide.stats[i].value,
                style: AppTextStyles.inter.copyWith(
                  fontSize: 23,
                  fontWeight: FontWeight.w800,
                  color: _fg,
                ),
              ),
            ],
          ),
        ),
        if (i < slide.stats.length - 1)
          Divider(height: 1, color: Colors.white.withValues(alpha: 0.16)),
      ],
    ],
  );

  Widget _compare() {
    final c = slide.compare!;
    Widget cell(String period, String amt, {bool now = false}) => Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: now ? 0.20 : 0.12),
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period.toUpperCase(),
            style: AppTextStyles.inter.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 1,
              color: _muted,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            amt,
            style: AppTextStyles.inter.copyWith(
              fontSize: 30,
              fontWeight: FontWeight.w800,
              color: _fg,
            ),
          ),
        ],
      ),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _emphasised(
          slide.title,
          base: AppTextStyles.inter.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.1,
            color: _fg,
          ),
        ),
        const SizedBox(height: 20),
        cell(c.priorLabel, c.prior),
        const SizedBox(height: 12),
        cell(c.nowLabel, c.now, now: true),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(KuberRadius.full),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(storyIcon(c.deltaIcon), size: 17, color: Colors.white),
              const SizedBox(width: 5),
              Text(
                c.delta,
                style: AppTextStyles.inter.copyWith(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: _fg,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statement() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _emphasised(
        slide.title,
        base: AppTextStyles.inter.copyWith(
          fontSize: 30,
          fontWeight: FontWeight.w800,
          height: 1.12,
          color: _fg,
        ),
      ),
      if (slide.subtitle != null) ...[
        const SizedBox(height: 16),
        _emphasised(
          slide.subtitle!,
          base: AppTextStyles.inter.copyWith(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            height: 1.45,
            color: _subtle,
          ),
        ),
      ],
    ],
  );

  Widget _emphasised(String text, {required TextStyle base}) {
    if (slide.emphasis.isEmpty) return Text(text, style: base);
    final spans = <({int start, int end, EmphasisStyle style})>[];
    for (final e in slide.emphasis) {
      if (e.token.isEmpty) continue;
      final start = text.indexOf(e.token);
      if (start == -1) continue;
      final end = start + e.token.length;
      if (spans.any((s) => start < s.end && end > s.start)) continue;
      spans.add((start: start, end: end, style: e.style));
    }
    if (spans.isEmpty) return Text(text, style: base);
    spans.sort((a, b) => a.start.compareTo(b.start));

    Color styleColor(EmphasisStyle style) => switch (style) {
      EmphasisStyle.bold => Colors.white,
      EmphasisStyle.primary => const Color(0xFFBFD4FF),
      EmphasisStyle.warning => const Color(0xFFFCD9A8),
    };

    final children = <TextSpan>[];
    var cursor = 0;
    for (final span in spans) {
      if (span.start > cursor) {
        children.add(TextSpan(text: text.substring(cursor, span.start)));
      }
      children.add(
        TextSpan(
          text: text.substring(span.start, span.end),
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: styleColor(span.style),
          ),
        ),
      );
      cursor = span.end;
    }
    if (cursor < text.length) {
      children.add(TextSpan(text: text.substring(cursor)));
    }
    return Text.rich(TextSpan(style: base, children: children));
  }
}
