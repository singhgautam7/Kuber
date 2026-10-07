import 'package:flutter/material.dart';

import '../../core/models/info_config.dart';
import 'kuber_info_bottom_sheet.dart';
import 'kuber_list.dart';

/// Home widget section header: the spec section header (labelMedium caps,
/// onSurfaceVariant) with the help glyph inline and an optional trailing slot.
class KuberHomeWidgetTitle extends StatelessWidget {
  final String title;
  final KuberInfoConfig? infoConfig;
  final Widget? trailing;

  /// Extra inline widgets after the title (Beta pill).
  final List<Widget> inline;

  const KuberHomeWidgetTitle({
    super.key,
    required this.title,
    this.infoConfig,
    this.trailing,
    this.inline = const [],
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    // "QUICK ADD (BETA)" -> "QUICK ADD" + a Beta pill (review round 2).
    final (label, tag) = splitTrailingTag(title);
    return KuberSectionHeader(
      title: label,
      onTitleTap: infoConfig != null
          ? () => KuberInfoBottomSheet.show(context, infoConfig!)
          : null,
      inline: [
        if (infoConfig != null)
          Icon(Icons.help_outline_rounded, size: 18, color: cs.onSurfaceVariant),
        if (tag != null) KuberPill(label: tag),
        ...inline,
      ],
      trailing: trailing,
    );
  }
}
