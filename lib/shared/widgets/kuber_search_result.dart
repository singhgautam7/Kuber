import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'kuber_list.dart';
import 'kuber_skeleton.dart';

/// [text] with the part matching [query] marked: primary, bold, on a 12%
/// primary wash.
class KuberMatchText extends StatelessWidget {
  final String text;
  final String query;
  final TextStyle style;
  final int? maxLines;

  const KuberMatchText({
    super.key,
    required this.text,
    required this.query,
    required this.style,
    this.maxLines,
  });

  @override
  Widget build(BuildContext context) {
    final i = query.isEmpty ? -1 : text.toLowerCase().indexOf(query.toLowerCase());
    if (i < 0) {
      return Text(text, maxLines: maxLines, overflow: maxLines == null ? null : TextOverflow.ellipsis, style: style);
    }
    final cs = Theme.of(context).colorScheme;
    final end = (i + query.length).clamp(0, text.length);
    return Text.rich(
      TextSpan(
        style: style,
        children: [
          TextSpan(text: text.substring(0, i)),
          TextSpan(
            text: text.substring(i, end),
            style: style.copyWith(
              color: cs.primary,
              fontWeight: FontWeight.w700,
              backgroundColor: cs.primary.withValues(alpha: 0.12),
            ),
          ),
          TextSpan(text: text.substring(end)),
        ],
      ),
      maxLines: maxLines,
      overflow: maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}

/// One search result (Components 2m): lead tile by type, title with the matched
/// letters, second line, optional "Matches:" line.
class KuberSearchResultRow extends StatelessWidget {
  final Widget leading;
  final String title;
  final String query;
  final String subtitle;

  /// "Matches: dark": the keyword that found a row its title doesn't show.
  final String? matches;
  final Widget? trailing;
  final VoidCallback? onTap;

  const KuberSearchResultRow({
    super.key,
    required this.leading,
    required this.title,
    required this.query,
    required this.subtitle,
    this.matches,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return InkWell(
      onTap: onTap,
      overlayColor: kuberPressedLayer(cs),
      child: Container(
        constraints: BoxConstraints(minHeight: matches == null ? 64 : KuberSpace.listItem3),
        padding: const EdgeInsets.symmetric(horizontal: KuberSpace.lg, vertical: 10),
        child: Row(
          children: [
            leading,
            const SizedBox(width: KuberSpace.lg),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  KuberMatchText(
                    text: title,
                    query: query,
                    // One line, unless the font is too large for that to read.
                    maxLines: MediaQuery.textScalerOf(context).scale(16) > 20 ? 3 : 1,
                    style: theme.textTheme.titleMedium!.copyWith(color: cs.onSurface),
                  ),
                  Text(subtitle, style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                  if (matches != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Row(
                        children: [
                          Icon(Icons.manage_search_rounded, size: 16, color: cs.primary),
                          const SizedBox(width: KuberSpace.xs),
                          Expanded(
                            child: KuberMatchText(
                              text: matches!,
                              query: query,
                              style: theme.textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: KuberSpace.lg),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}

/// A placeholder group while data results load.
class KuberSearchSkeleton extends StatelessWidget {
  final int rows;
  const KuberSearchSkeleton({super.key, this.rows = 3});

  @override
  Widget build(BuildContext context) {
    const widths = [(0.62, 0.40), (0.48, 0.56), (0.70, 0.34)];
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 24 + KuberSpace.sectionHeaderGap,
            child: Align(
              alignment: AlignmentDirectional.topStart,
              child: Padding(
                padding: EdgeInsets.only(top: 7),
                child: KuberSkeleton(width: 72, height: 10, borderRadius: KuberShape.full),
              ),
            ),
          ),
          KuberGroup(
            children: [
              for (final (a, b) in widths.take(rows))
                Container(
                  constraints: const BoxConstraints(minHeight: 64),
                  padding: const EdgeInsets.symmetric(horizontal: KuberSpace.lg, vertical: 10),
                  child: Row(
                    children: [
                      const KuberSkeleton(width: 40, height: 40),
                      const SizedBox(width: KuberSpace.lg),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (_, box) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              KuberSkeleton(width: box.maxWidth * a, height: 12, borderRadius: KuberShape.full),
                              const SizedBox(height: KuberSpace.sm),
                              KuberSkeleton(width: box.maxWidth * b, height: 10, borderRadius: KuberShape.full),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
