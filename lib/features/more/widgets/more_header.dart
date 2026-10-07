import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/app_icon_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_menu.dart';
import '../../settings/providers/settings_provider.dart';
import '../screens/more_search_screen.dart';

/// More tab header (board 3.7): "More", no description; search and an
/// overflow that switches the layout (the same setting as Settings → More Tab
/// Layout).
class MoreHeader extends ConsumerWidget {
  const MoreHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KuberAppBar(
      title: context.l10n.navMore,
      actions: [
        AppIconButton(
          icon: Icons.search_rounded,
          semanticLabel: 'Search',
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => MoreSearchScreen(hostContext: context),
            ),
          ),
        ),
        const _LayoutMenuButton(),
      ],
    );
  }
}

class _LayoutMenuButton extends ConsumerStatefulWidget {
  const _LayoutMenuButton();

  @override
  ConsumerState<_LayoutMenuButton> createState() => _LayoutMenuButtonState();
}

class _LayoutMenuButtonState extends ConsumerState<_LayoutMenuButton> {
  bool _open = false;

  Future<void> _show(BuildContext anchor) async {
    final current = ref.read(moreTabLayoutProvider);
    setState(() => _open = true);
    final picked = await showKuberMenu<MoreTabLayout>(
      context: anchor,
      minWidth: 232,
      entries: [
        KuberMenuEntry.header(context.l10n.changeView),
        KuberMenuEntry(
          value: MoreTabLayout.simple,
          label: 'Classic',
          subtitle: 'Grouped lists',
          icon: Icons.view_agenda_outlined,
          selected: current == MoreTabLayout.simple,
        ),
        KuberMenuEntry(
          value: MoreTabLayout.modern,
          label: 'Modern',
          subtitle: 'Hero, grid and cards',
          icon: Icons.dashboard_outlined,
          selected: current == MoreTabLayout.modern,
        ),
      ],
    );
    if (mounted) setState(() => _open = false);
    if (picked != null && picked != current) {
      await ref.read(settingsProvider.notifier).setMoreTabLayout(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (anchor) => AppIconButton(
        icon: Icons.more_vert_rounded,
        semanticLabel: 'More options',
        kind: _open ? AppIconButtonKind.tonal : AppIconButtonKind.standard,
        onPressed: () => _show(anchor),
      ),
    );
  }
}
