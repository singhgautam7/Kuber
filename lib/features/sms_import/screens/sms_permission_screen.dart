import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/locale_font.dart';
import '../../../shared/widgets/app_button.dart';

/// Which permission state the [SmsPermissionView] should render.
enum SmsPermissionMode { ask, softDenied, permaDenied }

/// The permission-flow body (Section 02). Three states sharing the paste
/// fallback. Stateless; the parent screen owns permission status + actions.
class SmsPermissionView extends StatelessWidget {
  final SmsPermissionMode mode;
  final VoidCallback onRequest;
  final VoidCallback onOpenSettings;
  final VoidCallback onPaste;

  const SmsPermissionView({
    super.key,
    required this.mode,
    required this.onRequest,
    required this.onOpenSettings,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    switch (mode) {
      case SmsPermissionMode.ask:
        return _AskView(onRequest: onRequest, onPaste: onPaste);
      case SmsPermissionMode.softDenied:
        return _SoftDeniedView(onRequest: onRequest, onPaste: onPaste);
      case SmsPermissionMode.permaDenied:
        return _PermaDeniedView(
          onOpenSettings: onOpenSettings,
          onPaste: onPaste,
        );
    }
  }
}

class _AskView extends StatelessWidget {
  final VoidCallback onRequest;
  final VoidCallback onPaste;
  const _AskView({required this.onRequest, required this.onPaste});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 18),
                    Center(child: _HeroGlyph()),
                    const SizedBox(height: 16),
                    Text(
                      'Auto-detect every\nbank transaction.',
                      textAlign: TextAlign.center,
                      style: localeFont(
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        color: cs.onSurface,
                        height: 1.12,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Kuber reads transaction SMS from known Indian banks '
                      'and suggests them for import. Nothing leaves your phone.',
                      textAlign: TextAlign.center,
                      style: localeFont(
                        fontSize: 13.5,
                        height: 1.5,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 22),
                    const _ValueBullet(
                      icon: Icons.search_rounded,
                      title: 'HDFC, SBI, ICICI, Axis, Kotak + 15 more',
                      body: 'All major Indian banks and UPI senders.',
                    ),
                    const SizedBox(height: 10),
                    const _ValueBullet(
                      icon: Icons.task_alt_rounded,
                      title: 'Learns your accounts',
                      body:
                          'After 3 imports from the same sender, the account '
                          'auto-fills.',
                    ),
                    const SizedBox(height: 10),
                    const _ValueBullet(
                      icon: Icons.lock_outline_rounded,
                      title: 'OTPs are never read',
                      body:
                          'Messages containing OTP or verification codes are '
                          'skipped before parsing.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.shield_outlined, size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Read-only access. Nothing is stored or transmitted '
                    'without your approval.',
                    style: localeFont(
                      fontSize: 11.5,
                      height: 1.4,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Allow SMS access',
              type: AppButtonType.primary,
              fullWidth: true,
              onPressed: onRequest,
            ),
            const SizedBox(height: 6),
            TextButton(
              onPressed: onPaste,
              child: Text(
                'Paste a single SMS instead',
                style: localeFont(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroGlyph extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(KuberRadius.xl),
              border: Border.all(color: cs.primary.withValues(alpha: 0.25)),
            ),
            child: Icon(
              Icons.sms_outlined,
              size: 40,
              color: cs.primary,
            ),
          ),
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: cs.surface,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: cs.primary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ValueBullet extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  const _ValueBullet({
    required this.icon,
    required this.title,
    required this.body,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: cs.primary.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
            child: Icon(icon, size: 14, color: cs.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: localeFont(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  body,
                  style: localeFont(
                    fontSize: 11.5,
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SoftDeniedView extends StatelessWidget {
  final VoidCallback onRequest;
  final VoidCallback onPaste;
  const _SoftDeniedView({required this.onRequest, required this.onPaste});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return _CenteredState(
      iconColor: cs.onSurfaceVariant,
      iconBg: cs.surfaceContainer,
      iconBorder: cs.outline,
      icon: Icons.sms_failed_outlined,
      title: 'SMS access not granted.',
      body: 'No problem. You can still import by pasting an SMS one at a time, '
          'or try the permission again.',
      primary: AppButton(
        label: 'Try again',
        type: AppButtonType.primary,
        fullWidth: true,
        onPressed: onRequest,
      ),
      secondary: AppButton(
        label: 'Paste a single SMS',
        type: AppButtonType.outline,
        fullWidth: true,
        onPressed: onPaste,
      ),
    );
  }
}

class _PermaDeniedView extends StatelessWidget {
  final VoidCallback onOpenSettings;
  final VoidCallback onPaste;
  const _PermaDeniedView({
    required this.onOpenSettings,
    required this.onPaste,
  });

  @override
  Widget build(BuildContext context) {
    final warning = context.kuberColors.warning;
    return _CenteredState(
      iconColor: warning,
      iconBg: warning.withValues(alpha: 0.12),
      iconBorder: warning.withValues(alpha: 0.30),
      icon: Icons.error_outline_rounded,
      title: 'SMS access is blocked.',
      body: 'Open system Settings and enable the SMS permission for Kuber to '
          'use auto-import.',
      extra: const _SettingsHintCard(),
      primary: AppButton(
        label: 'Open Settings',
        type: AppButtonType.primary,
        fullWidth: true,
        icon: Icons.north_east_rounded,
        iconAfterLabel: true,
        onPressed: onOpenSettings,
      ),
      secondary: AppButton(
        label: 'Paste a single SMS',
        type: AppButtonType.outline,
        fullWidth: true,
        onPressed: onPaste,
      ),
    );
  }
}

class _SettingsHintCard extends StatelessWidget {
  const _SettingsHintCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    Widget crumb(String text, {bool strong = false}) => Text(
          text,
          style: localeFont(
            fontSize: 12.5,
            fontWeight: strong ? FontWeight.w600 : FontWeight.w400,
            color: strong ? cs.onSurface : cs.onSurfaceVariant,
          ),
        );
    Widget chevron() =>
        Icon(Icons.chevron_right_rounded, size: 14, color: cs.onSurfaceVariant);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 22),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WHAT TO LOOK FOR IN SETTINGS',
            style: localeFont(
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: cs.onSurfaceVariant,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            children: [
              crumb('Apps'),
              chevron(),
              crumb('Kuber'),
              chevron(),
              crumb('Permissions'),
              chevron(),
              crumb('SMS', strong: true),
            ],
          ),
        ],
      ),
    );
  }
}

/// Shared centered empty/denied layout with a hero icon, title, body and up to
/// two stacked buttons.
class _CenteredState extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color iconBorder;
  final String title;
  final String body;
  final Widget? extra;
  final Widget primary;
  final Widget? secondary;

  const _CenteredState({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.iconBorder,
    required this.title,
    required this.body,
    this.extra,
    required this.primary,
    this.secondary,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 40, 24, 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Container(
              width: 76,
              height: 76,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: iconBorder),
              ),
              child: Icon(icon, size: 34, color: iconColor),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: localeFont(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
                letterSpacing: -0.6,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              textAlign: TextAlign.center,
              style: localeFont(
                fontSize: 13.5,
                height: 1.5,
                color: cs.onSurfaceVariant,
              ),
            ),
            ?extra,
            const Spacer(),
            primary,
            if (secondary != null) ...[
              const SizedBox(height: 8),
              secondary!,
            ],
          ],
        ),
      ),
    );
  }
}
