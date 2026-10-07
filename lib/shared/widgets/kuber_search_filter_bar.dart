import 'package:flutter/material.dart';

import 'app_icon_button.dart';
import 'kuber_menu.dart';

/// The filter icon button of a list's summary row (Kuber Cards, Kuber
/// Notes). Fills while a filter is applied.
class KuberFilterButton extends StatelessWidget {
  final VoidCallback onPressed;
  final bool active;

  const KuberFilterButton({
    super.key,
    required this.onPressed,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppIconButton(
      icon: Icons.tune_rounded,
      size: 40,
      glyphSize: 20,
      kind: active ? AppIconButtonKind.filled : AppIconButtonKind.standard,
      semanticLabel: active ? 'Filters applied' : 'Filter',
      onPressed: onPressed,
    );
  }
}

/// The change-view icon button (Perch's `ViewModeButton`): the glyph is the
/// current mode, tapping opens a menu of the modes with the current one
/// checked.
class KuberViewModeButton<T> extends StatelessWidget {
  final T value;
  final List<(T, IconData, String)> options;
  final ValueChanged<T> onChanged;

  const KuberViewModeButton({
    super.key,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final current = options.firstWhere((o) => o.$1 == value);
    return Builder(
      builder: (anchor) => AppIconButton(
        icon: current.$2,
        size: 40,
        glyphSize: 20,
        semanticLabel: '${current.$3}. Change view',
        onPressed: () async {
          final picked = await showKuberMenu<T>(
            context: anchor,
            minWidth: 180,
            entries: [
              for (final (v, icon, label) in options)
                KuberMenuEntry<T>(
                  value: v,
                  label: label,
                  icon: icon,
                  selected: v == value,
                ),
            ],
          );
          if (picked != null && picked != value) onChanged(picked);
        },
      ),
    );
  }
}
