import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/brand_icon.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../settings/providers/settings_provider.dart';
import '../widgets/onboarding_entrance.dart';
import '../widgets/onboarding_fit.dart';
import '../widgets/setup_language_row.dart';

/// First page of a fresh install: language, then restore a backup, import a
/// CSV, or Start fresh (the button is in the flow's nav bar).
class OnboardingStartPage extends ConsumerWidget {
  final VoidCallback onRestore;
  final VoidCallback onImportCsv;

  const OnboardingStartPage({
    super.key,
    required this.onRestore,
    required this.onImportCsv,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final locale = ref.watch(localeProvider);
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.only(top: KuberSpace.lg),
        child: OnboardingFit(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              KuberGroup(
                children: [
                  SetupLanguageRow(selectedLocale: locale, onLocaleChanged: (_) {}),
                ],
              ),
              const SizedBox(height: KuberSpace.xxl),
              OnboardingEntrance(
                child: Column(
                  children: [
                    const BrandIcon(size: 88),
                    const SizedBox(height: KuberSpace.lg),
                    Text(
                      'Kuber',
                      style: localeFont(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KuberSpace.xxl),
              OnboardingEntrance(
                delay: const Duration(milliseconds: 160),
                child: KuberGroup(
                  children: [
                    KuberListRow(
                      leading: const KuberIconTile(icon: Icons.settings_backup_restore_rounded),
                      title: l.obStartRestore,
                      subtitle: l.obStartRestoreSub,
                      subtitleLines: 2,
                      trailing: const KuberChevron(),
                      onTap: onRestore,
                    ),
                    KuberListRow(
                      leading: const KuberIconTile(icon: Icons.table_chart_outlined),
                      title: l.obStartCsv,
                      subtitle: l.obStartCsvSub,
                      subtitleLines: 2,
                      trailing: const KuberChevron(),
                      onTap: onImportCsv,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
