import 'package:flutter/material.dart';

enum SlideVariant { hero, stats, compare, statement }

enum EmphasisStyle { bold, primary, warning }

// `plum` is reserved for the first-launch Welcome story only — deliberately
// outside the eight type colours so it reads as an intro, not a category.
enum StoryColorKey { violet, amber, rose, emerald, cyan, blue, gold, slate, plum }

class StoryPalette {
  static const Map<StoryColorKey, Color> background = {
    StoryColorKey.violet: Color(0xFF5A4FCF),
    StoryColorKey.amber: Color(0xFFC9760E),
    StoryColorKey.rose: Color(0xFFC0364F),
    StoryColorKey.emerald: Color(0xFF0E8A5F),
    StoryColorKey.cyan: Color(0xFF0E7C9B),
    StoryColorKey.blue: Color(0xFF2563EB),
    StoryColorKey.gold: Color(0xFFB07A12),
    StoryColorKey.slate: Color(0xFF3F4654),
    StoryColorKey.plum: Color(0xFF6B2774),
  };

  static const Map<StoryColorKey, Color> ring = {
    StoryColorKey.violet: Color(0xFF7C6FF0),
    StoryColorKey.amber: Color(0xFFF59E0B),
    StoryColorKey.rose: Color(0xFFF43F5E),
    StoryColorKey.emerald: Color(0xFF22C55E),
    StoryColorKey.cyan: Color(0xFF22B8DD),
    StoryColorKey.blue: Color(0xFF3B82F6),
    StoryColorKey.gold: Color(0xFFEAB308),
    StoryColorKey.slate: Color(0xFF64748B),
    StoryColorKey.plum: Color(0xFFC026D3),
  };

  static StoryColorKey keyFromString(String s) => StoryColorKey.values
      .firstWhere((e) => e.name == s, orElse: () => StoryColorKey.blue);
}

class Emphasis {
  final String token;
  final EmphasisStyle style;
  const Emphasis(this.token, this.style);

  factory Emphasis.fromJson(Map<String, dynamic> json) => Emphasis(
    json['token'] as String,
    EmphasisStyle.values.firstWhere(
      (e) => e.name == (json['emphasisStyle'] ?? 'bold'),
      orElse: () => EmphasisStyle.bold,
    ),
  );

  Map<String, dynamic> toJson() => {
    'token': token,
    'emphasisStyle': style.name,
  };
}

class StatItem {
  final String label;
  final String value;
  const StatItem(this.label, this.value);

  factory StatItem.fromJson(Map<String, dynamic> json) =>
      StatItem(json['label'] as String, json['value'] as String);

  Map<String, dynamic> toJson() => {'label': label, 'value': value};
}

class CompareData {
  final String priorLabel;
  final String prior;
  final String nowLabel;
  final String now;
  final String deltaIcon;
  final String delta;

  const CompareData({
    required this.priorLabel,
    required this.prior,
    required this.nowLabel,
    required this.now,
    required this.deltaIcon,
    required this.delta,
  });

  factory CompareData.fromJson(Map<String, dynamic> json) => CompareData(
    priorLabel: json['priorLabel'] as String,
    prior: json['prior'] as String,
    nowLabel: json['nowLabel'] as String,
    now: json['now'] as String,
    deltaIcon: json['deltaIcon'] as String,
    delta: json['delta'] as String,
  );

  Map<String, dynamic> toJson() => {
    'priorLabel': priorLabel,
    'prior': prior,
    'nowLabel': nowLabel,
    'now': now,
    'deltaIcon': deltaIcon,
    'delta': delta,
  };
}

class StorySlide {
  final SlideVariant variant;
  final StoryColorKey background;
  final String icon;
  final String? header;

  /// Low-emphasis period label rendered under the header (e.g. "May 2026",
  /// "18 May to 24 May 2026"). Omitted for pace comparisons, insights, welcome.
  final String? dateLabel;
  final String title;
  final String? subtitle;
  final String? footer;
  final List<Emphasis> emphasis;
  final String? hero;
  final List<StatItem> stats;
  final CompareData? compare;

  const StorySlide({
    required this.variant,
    required this.background,
    required this.icon,
    required this.title,
    this.header,
    this.dateLabel,
    this.subtitle,
    this.footer,
    this.emphasis = const [],
    this.hero,
    this.stats = const [],
    this.compare,
  });

  factory StorySlide.fromJson(Map<String, dynamic> json) => StorySlide(
    variant: SlideVariant.values.firstWhere(
      (e) => e.name == json['variant'],
      orElse: () => SlideVariant.hero,
    ),
    background: StoryPalette.keyFromString(json['background'] as String),
    icon: json['icon'] as String,
    header: json['header'] as String?,
    dateLabel: json['dateLabel'] as String?,
    title: json['title'] as String? ?? '',
    subtitle: json['subtitle'] as String?,
    footer: json['footer'] as String?,
    emphasis: ((json['emphasis'] as List?) ?? [])
        .map((e) => Emphasis.fromJson(e as Map<String, dynamic>))
        .toList(),
    hero: json['hero'] as String?,
    stats: ((json['stats'] as List?) ?? [])
        .map((e) => StatItem.fromJson(e as Map<String, dynamic>))
        .toList(),
    compare: json['compare'] == null
        ? null
        : CompareData.fromJson(json['compare'] as Map<String, dynamic>),
  );

  Map<String, dynamic> toJson() => {
    'variant': variant.name,
    'background': background.name,
    'icon': icon,
    if (header != null) 'header': header,
    if (dateLabel != null) 'dateLabel': dateLabel,
    'title': title,
    if (subtitle != null) 'subtitle': subtitle,
    if (footer != null) 'footer': footer,
    if (emphasis.isNotEmpty)
      'emphasis': emphasis.map((e) => e.toJson()).toList(),
    if (hero != null) 'hero': hero,
    if (stats.isNotEmpty) 'stats': stats.map((e) => e.toJson()).toList(),
    if (compare != null) 'compare': compare!.toJson(),
  };
}

class StoryViewData {
  final int id;
  final String storyKey;
  final String type;
  final String label;
  final String icon;
  final StoryColorKey color;
  final String timeLabel;
  final DateTime generatedAt;
  final DateTime expiresAt;
  final DateTime? seenAt;
  final List<int> seenSlides;
  final List<StorySlide> slides;

  const StoryViewData({
    required this.id,
    required this.storyKey,
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.timeLabel,
    required this.generatedAt,
    required this.expiresAt,
    required this.seenAt,
    required this.seenSlides,
    required this.slides,
  });

  bool get seen => seenSlides.length == slides.length;
}

/// One ring bubble = all currently active stories of a single [type], in the
/// order the viewer should play them (unseen first, newest first).
class StoryBubble {
  final String type;
  final String label;
  final String icon;
  final StoryColorKey color;
  final List<StoryViewData> stories;

  const StoryBubble({
    required this.type,
    required this.label,
    required this.icon,
    required this.color,
    required this.stories,
  });

  /// The bubble reads as "seen" only when every story in it is fully seen.
  bool get seen => stories.every((s) => s.seen);
}
