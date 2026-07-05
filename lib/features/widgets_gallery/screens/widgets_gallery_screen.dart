import 'package:flutter/material.dart';

import '../../../core/models/info_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../data/widget_catalog.dart';
import '../widgets/widget_detail_sheet.dart';

/// Widgets gallery landing (More -> Widgets, route /more/widgets-gallery).
/// Universal landing structure: KuberAppBar + KuberPageHeader + grouped list.
class WidgetsGalleryScreen extends StatelessWidget {
  const WidgetsGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: KuberAppBar(
              title: 'Widgets',
              showBack: true,
              showHome: true,
              infoConfig: _aboutWidgetsInfo,
            ),
          ),
          const SliverToBoxAdapter(
            child: KuberPageHeader(
              title: 'Widgets',
              description: 'Home screen widgets to keep Kuber in view',
            ),
          ),
          _group(context, 'SMALL WIDGETS', WidgetSizeGroup.small),
          _group(context, 'MEDIUM WIDGETS', WidgetSizeGroup.medium),
          _group(context, 'LARGE WIDGETS', WidgetSizeGroup.large),
          const SliverToBoxAdapter(child: SizedBox(height: KuberSpacing.xxl)),
        ],
      ),
    );
  }

  Widget _group(BuildContext context, String heading, WidgetSizeGroup group) {
    final cs = Theme.of(context).colorScheme;
    final entries = kWidgetCatalog.where((e) => e.group == group).toList();
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(KuberSpacing.lg, 0, KuberSpacing.lg, KuberSpacing.lg),
      sliver: SliverList(
        delegate: SliverChildListDelegate([
          Padding(
            padding: const EdgeInsets.only(bottom: KuberSpacing.sm, left: 4),
            child: Text(
              heading,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: cs.onSurfaceVariant,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Column(
              children: [
                for (var i = 0; i < entries.length; i++) ...[
                  if (i > 0) Divider(height: 1, thickness: 0.5, color: cs.outlineVariant, indent: 16, endIndent: 16),
                  _row(context, entries[i]),
                ],
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _row(BuildContext context, WidgetCatalogEntry entry) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(KuberRadius.md),
      onTap: () => showWidgetDetailSheet(context, entry),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(entry.name, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: cs.onSurface)),
                  const SizedBox(height: 2),
                  Text(entry.description, style: TextStyle(fontSize: 12.5, color: cs.onSurfaceVariant)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(KuberRadius.sm),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Text(entry.sizeLabel, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: cs.onSurfaceVariant)),
            ),
            const SizedBox(width: 4),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
          ],
        ),
      ),
    );
  }
}

/// About Widgets info sheet content (opened via the app bar info button).
const KuberInfoConfig _aboutWidgetsInfo = KuberInfoConfig(
  title: 'Home screen widgets',
  description:
      'Kuber widgets put your money at a glance on your Android home screen, '
      'without opening the app.',
  items: [
    KuberInfoItem(
      icon: Icons.widgets_outlined,
      title: 'What they are',
      description:
          'Small native panels you place on your home screen. Each shows one slice '
          'of Kuber (net, an account, upcoming events, charts, notes and more).',
    ),
    KuberInfoItem(
      icon: Icons.add_to_home_screen_outlined,
      title: 'How to add one',
      description:
          'Open a widget here and tap "Add to Home", or long-press an empty spot on '
          'your home screen, choose Widgets, and find Kuber in the list.',
    ),
    KuberInfoItem(
      icon: Icons.touch_app_outlined,
      title: 'Tap to open',
      description:
          'Tapping a widget jumps straight to the matching screen in Kuber. Some '
          'widgets, like Trends, have controls right on the widget itself.',
    ),
    KuberInfoItem(
      icon: Icons.sync_outlined,
      title: 'Staying fresh',
      description:
          'Widgets refresh when the underlying data changes and roughly every 30 '
          'minutes in the background, so they stay current on their own.',
    ),
    KuberInfoItem(
      icon: Icons.lock_outline,
      title: 'Private by design',
      description:
          'Widget data is stored locally on your device, exactly like the rest of '
          'Kuber. Nothing is uploaded to add or update a widget.',
    ),
  ],
);
