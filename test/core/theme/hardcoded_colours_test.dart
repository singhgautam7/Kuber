// Lint (theme-surfaces-v1): UI colours come from the scheme or Kuber tokens
// (CLAUDE.md rule 1), so every theme, Expressive colours and Pure black reach
// every screen. Only content colours that must look the same in every theme
// may be literal; each such file has a fixed budget below. A new literal, or
// one more in a listed file, fails this test.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

const _allowed = <String, int>{
  // PDF export pages (not the app theme).
  'lib/core/services/export_service.dart': 3,
  // Account and card colour palettes the user picks from.
  'lib/core/utils/account_helpers.dart': 3,
  'lib/core/utils/card_palette.dart': 2,
  'lib/shared/widgets/card_color_gradient_picker.dart': 3,
  'lib/features/kuber_cards/widgets/stored_card_visual.dart': 6,
  // Shimmer masks (shape only) and labels on category colours.
  'lib/features/analytics/widgets/budget_vs_actual.dart': 3,
  'lib/features/analytics/widgets/category_group_stats.dart': 3,
  'lib/features/dashboard/widgets/burn_rate_card.dart': 1,
  // Dev tools (true / false chips).
  'lib/features/dev/widgets/record_detail_sheet.dart': 6,
  // About footer heart.
  'lib/features/more/screens/about_screen.dart': 1,
  // Welcome coin art.
  'lib/features/onboarding/pages/onboarding_page_1.dart': 7,
  // Pure black swatch on the Theme screen (it shows #000000 by design).
  'lib/features/settings/screens/theme_screen.dart': 1,
  // Import overlay scrim.
  'lib/features/settings/widgets/data_action_widgets.dart': 1,
  // Money Stories: full-screen story art.
  'lib/features/stories/models/story_models.dart': 18,
  'lib/features/stories/widgets/story_slide_view.dart': 15,
  'lib/features/stories/widgets/story_viewer.dart': 12,
  // Person avatars and tool accents (fixed per person / per tool).
  'lib/features/tools/bill_splitter/widgets/bs_avatar.dart': 18,
  'lib/shared/widgets/person_avatar.dart': 10,
  'lib/features/tools/widgets/tool_accents.dart': 7,
  // Why Kuber demo screens.
  'lib/features/why_kuber/data/why_kuber_demo_data.dart': 7,
  // Brand marks.
  'lib/shared/widgets/brand_icon.dart': 6,
};

void main() {
  test('no hardcoded colours outside the theme and the content allow-list', () {
    final literal = RegExp(r'Color\(0x[0-9A-Fa-f]{8}\)|Colors\.(?!transparent\b)[a-zA-Z]+');
    final over = <String>[];
    for (final f in Directory('lib').listSync(recursive: true).whereType<File>()) {
      final path = f.path.replaceAll(r'\', '/');
      if (!path.endsWith('.dart') || path.endsWith('.g.dart')) continue;
      if (path.startsWith('lib/core/theme/') || path.startsWith('lib/l10n/')) continue;
      var n = 0;
      for (final line in f.readAsLinesSync()) {
        if (line.trimLeft().startsWith('//')) continue;
        n += literal.allMatches(line).length;
      }
      if (n > (_allowed[path] ?? 0)) over.add('$path: $n (allowed ${_allowed[path] ?? 0})');
    }
    expect(over, isEmpty, reason: 'Use Theme.of(context).colorScheme or Kuber tokens');
  });
}
