import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';

const kPrivacyPolicyUrl = 'https://kuber.pages.dev/docs/privacy-policy/';

/// Data responsibility, the last page. Layout (top to bottom): a quiet icon,
/// the two checkboxes, then title and description sitting on the flow's
/// button. Scrolls at large font sizes.
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
    Widget check(bool value, ValueChanged<bool> onChanged, String text) => CheckboxListTile(
          value: value,
          onChanged: (v) => onChanged(v ?? false),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
          title: Text(text, style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurface)),
        );
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: KuberSpace.xl),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: KuberSpace.xxl),
                Icon(Icons.phone_android_rounded, size: 56, color: cs.onSurfaceVariant),
                const Spacer(),
                check(backups, onBackups, l.obTermsCheck1),
                check(responsibility, onResponsibility, l.obTermsCheck2),
                const Spacer(),
                Text(l.obTermsTitle,
                    style: theme.textTheme.headlineMedium!.copyWith(color: cs.onSurface)),
                const SizedBox(height: KuberSpace.sm),
                Text(l.obTermsBody,
                    style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
                Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: TextButton(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero),
                    onPressed: () => launchUrl(Uri.parse(kPrivacyPolicyUrl),
                        mode: LaunchMode.externalApplication),
                    child: Text(l.obTermsPrivacy),
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
