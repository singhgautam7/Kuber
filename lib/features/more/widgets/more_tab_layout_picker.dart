// More Tab Layout picker — uses the existing SettingsChoiceSheet pattern.
//
// This is intentionally a *bottom sheet*, not a full-page screen. Mirrors
// the existing "Bottom Navigation" picker in settings_screen.dart so the
// two appearance toggles feel identical.
//
// Wiring: from settings_screen.dart, add this alongside _showBottomNavSheet:
//
//   void _showMoreTabLayoutSheet(BuildContext context, MoreTabLayout current) {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       useSafeArea: true,
//       useRootNavigator: true,
//       backgroundColor: Colors.transparent,
//       builder: (_) => SettingsChoiceSheet<MoreTabLayout>(
//         title: 'More Tab Layout',
//         subtitle: 'Appearance',
//         selectedValue: current,
//         choices: moreTabLayoutChoices,
//         onSelected: (val) {
//           setState(() => _tempMoreTabLayout = val);
//           ref.read(settingsProvider.notifier).setMoreTabLayout(val);
//         },
//       ),
//     );
//   }
//
// The new Settings row uses the same `_SettingsTile` widget that's already
// in the file; nothing custom is needed.

import 'package:flutter/material.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../settings/widgets/settings_choice_sheet.dart';
import '../../settings/providers/settings_provider.dart';

/// Pass this to `SettingsChoiceSheet<MoreTabLayout>(choices: ...)`.
List<SettingsChoice<MoreTabLayout>> moreTabLayoutChoices(
  BuildContext context,
) => [
  SettingsChoice(
    value: MoreTabLayout.simple,
    label: context.l10n.simpleLabel,
    subtitle: context.l10n.moreTabSimpleSubtitle,
    icon: Icons.view_list_rounded,
  ),
  SettingsChoice(
    value: MoreTabLayout.modern,
    label: context.l10n.navModernChoice,
    subtitle: context.l10n.moreTabModernSubtitle,
    icon: Icons.grid_view_rounded,
  ),
];
