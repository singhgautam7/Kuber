import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_option_card.dart';

const kPrivacyPolicyUrl = 'https://kuber.pages.dev/docs/privacy-policy/';

/// Your data, the last page: both boxes are required. Scrolls at large font
/// sizes.
class OnboardingDataTermsPage extends StatelessWidget {
  final bool backups;
  final bool responsibility;
  final ValueChanged<bool> onBackups;
  final ValueChanged<bool> onResponsibility;

  const OnboardingDataTermsPage({
    super.key,
    required this.backups,
    required this.responsibility,
    required this.onBackups,
    required this.onResponsibility,
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(KuberSpace.screenMargin, 56, KuberSpace.screenMargin, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 88,
                    height: 88,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.surfaceContainerLow,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: const KuberIconTile(icon: Icons.shield_outlined, size: 56, glyph: 30, circle: true),
                  ),
                ),
                const SizedBox(height: KuberSpace.xl - 4),
                KuberConsentRow(text: l.obTermsCheck1, value: backups, onChanged: onBackups),
                const SizedBox(height: KuberSpace.md),
                KuberConsentRow(text: l.obTermsCheck2, value: responsibility, onChanged: onResponsibility),
                const SizedBox(height: KuberSpace.xl),
                Text(l.obTermsTitle, style: theme.textTheme.titleLarge!.copyWith(color: cs.onSurface)),
                const SizedBox(height: 6),
                Text(l.obTermsBody, style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(height: 6),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: InkWell(
                    onTap: () => launchUrl(Uri.parse(kPrivacyPolicyUrl), mode: LaunchMode.externalApplication),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: KuberSpace.tapTarget),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Flexible(
                            child: Text(l.obTermsPrivacy,
                                style: theme.textTheme.labelLarge!.copyWith(color: cs.primary)),
                          ),
                          const SizedBox(width: KuberSpace.xs),
                          Icon(Icons.open_in_new_rounded, size: 16, color: cs.primary),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
