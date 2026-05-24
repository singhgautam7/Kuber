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
import '../../settings/widgets/settings_choice_sheet.dart';
import '../../settings/providers/settings_provider.dart';

/// Pass this to `SettingsChoiceSheet<MoreTabLayout>(choices: ...)`.
const moreTabLayoutChoices = <SettingsChoice<MoreTabLayout>>[
  SettingsChoice(
    value: MoreTabLayout.simple,
    label: 'Simple',
    subtitle: 'Uniform list of cards. Familiar and predictable.',
    icon: Icons.view_list_rounded,
  ),
  SettingsChoice(
    value: MoreTabLayout.modern,
    label: 'Modern',
    subtitle:
        'Hero items, tile grid and compact lists. Differentiated by section.',
    icon: Icons.grid_view_rounded,
  ),
];
