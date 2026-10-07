import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/utils/color_palette.dart';
import '../../core/utils/icon_mapper.dart';
import '../../core/utils/l10n_ext.dart';
import 'app_button.dart';
import 'color_picker_bottom_sheet.dart';
import 'icon_picker_bottom_sheet.dart';
import 'kuber_bottom_sheet.dart';
import 'kuber_form_widgets.dart';
import 'kuber_segmented_control.dart';

enum IconColorTab { icon, colour }

/// One "Icon & colour" picker row (board 3.15): a live tile in the chosen
/// icon + colour, "Icon name · Colour name" and "Icon & colour" under it.
/// Tapping opens [showIconColorPicker].
class IconColorPickerRow extends StatelessWidget {
  final String iconKey;
  final int colorValue;
  final String label;
  final VoidCallback onTap;

  const IconColorPickerRow({
    super.key,
    required this.iconKey,
    required this.colorValue,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return KuberPickerRow(
      leading: KuberLeadingSwatch(
        color: Color(colorValue),
        icon: IconMapper.fromString(iconKey),
      ),
      label: label,
      value:
          '${IconMapper.labelFor(iconKey)} · ${AppColorPalette.nameFor(colorValue)}',
      onTap: onTap,
    );
  }
}

/// The Icon / Colour bottom sheet (board 3.15): segmented tabs, the icon
/// search + grid or the colour banks, and Done. Picks stay local until Done,
/// which reports both through [onDone]; closing discards them.
Future<void> showIconColorPicker({
  required BuildContext context,
  required List<String> iconKeys,
  required Map<String, List<String>> tags,
  required String iconKey,
  required int colorValue,
  required void Function(String iconKey, int colorValue) onDone,
  IconColorTab initialTab = IconColorTab.icon,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _IconColorSheet(
      iconKeys: iconKeys,
      tags: tags,
      iconKey: iconKey,
      colorValue: colorValue,
      onDone: onDone,
      initialTab: initialTab,
    ),
  );
}

class _IconColorSheet extends StatefulWidget {
  final List<String> iconKeys;
  final Map<String, List<String>> tags;
  final String iconKey;
  final int colorValue;
  final void Function(String, int) onDone;
  final IconColorTab initialTab;

  const _IconColorSheet({
    required this.iconKeys,
    required this.tags,
    required this.iconKey,
    required this.colorValue,
    required this.onDone,
    required this.initialTab,
  });

  @override
  State<_IconColorSheet> createState() => _IconColorSheetState();
}

class _IconColorSheetState extends State<_IconColorSheet> {
  late IconColorTab _tab = widget.initialTab;
  late String _icon = widget.iconKey;
  late int _color = widget.colorValue;

  @override
  Widget build(BuildContext context) {
    return KuberBottomSheet(
      title: _tab == IconColorTab.icon
          ? context.l10n.chooseIcon
          : context.l10n.chooseColour,
      leadingIcon: SizedBox(
        width: 48,
        height: 48,
        child: KuberLeadingSwatch(
          color: Color(_color),
          icon: IconMapper.fromString(_icon),
        ),
      ),
      actions: AppButton(
        label: context.l10n.doneLabel,
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: () {
          widget.onDone(_icon, _color);
          Navigator.of(context, rootNavigator: true).pop();
        },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KuberSegmentedControl<IconColorTab>(
            values: const [IconColorTab.icon, IconColorTab.colour],
            labels: [context.l10n.iconLabel, context.l10n.colorLabel],
            selected: _tab,
            onSelected: (t) => setState(() => _tab = t),
            height: 40,
          ),
          const SizedBox(height: KuberSpace.lg),
          if (_tab == IconColorTab.icon)
            IconPickerBody(
              iconKeys: widget.iconKeys,
              tags: widget.tags,
              selected: _icon,
              onSelected: (k) => setState(() => _icon = k),
            )
          else
            ColorPickerBody(
              selected: _color,
              onSelected: (v) => setState(() => _color = v),
            ),
        ],
      ),
    );
  }
}
