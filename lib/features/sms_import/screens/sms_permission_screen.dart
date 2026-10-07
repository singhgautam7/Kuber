import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_list.dart';

/// Which permission state the [SmsPermissionView] should render.
enum SmsPermissionMode { ask, softDenied, permaDenied }

/// The permission-flow body (board 3.9b): Ask, Not granted, Blocked. All three
/// keep the paste fallback. Stateless; the parent owns status and actions.
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
    final cs = Theme.of(context).colorScheme;
    switch (mode) {
      case SmsPermissionMode.ask:
        return _PermissionLayout(
          tileIcon: Icons.sms_outlined,
          tileBg: cs.secondaryContainer,
          tileFg: cs.onSecondaryContainer,
          title: 'Auto-detect every bank transaction.',
          body:
              'Kuber reads transaction SMS from known Indian banks and '
              'suggests them for import. Nothing leaves your phone.',
          extra: const _AskDetails(),
          primary: AppButton(
            label: 'Allow SMS access',
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: onRequest,
          ),
          secondary: TextButton(
            onPressed: onPaste,
            child: const Text('Paste a single SMS instead'),
          ),
        );
      case SmsPermissionMode.softDenied:
        return _PermissionLayout(
          centered: true,
          tileIcon: Icons.sms_failed_outlined,
          tileBg: cs.surfaceContainerHigh,
          tileFg: cs.onSurfaceVariant,
          title: 'SMS access not granted.',
          body:
              'No problem. You can still import by pasting an SMS one at a '
              'time, or try the permission again.',
          primary: AppButton(
            label: 'Try again',
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: onRequest,
          ),
          secondary: AppButton(
            label: 'Paste a single SMS',
            icon: Icons.content_paste_rounded,
            type: AppButtonType.outline,
            fullWidth: true,
            onPressed: onPaste,
          ),
        );
      case SmsPermissionMode.permaDenied:
        return _PermissionLayout(
          centered: true,
          tileIcon: Icons.block_rounded,
          tileBg: cs.errorContainer,
          tileFg: cs.onErrorContainer,
          title: 'SMS access is blocked.',
          body:
              'Open system Settings and enable the SMS permission for Kuber '
              'to use auto-import.',
          extra: const _SettingsHint(),
          primary: AppButton(
            label: 'Open Settings',
            type: AppButtonType.primary,
            fullWidth: true,
            icon: Icons.open_in_new_rounded,
            iconAfterLabel: true,
            onPressed: onOpenSettings,
          ),
          secondary: AppButton(
            label: 'Paste a single SMS',
            icon: Icons.content_paste_rounded,
            type: AppButtonType.outline,
            fullWidth: true,
            onPressed: onPaste,
          ),
        );
    }
  }
}

/// 56 tile, headlineMedium title, bodyLarge copy, optional block, and the
/// actions pinned at the bottom. Left-aligned like the boards.
class _PermissionLayout extends StatelessWidget {
  final IconData tileIcon;
  final Color tileBg;
  final Color tileFg;
  final String title;
  final String body;
  final Widget? extra;
  final Widget primary;
  final Widget secondary;

  /// Not granted / Blocked sit in the vertical middle; Ask starts at the top.
  final bool centered;

  const _PermissionLayout({
    required this.tileIcon,
    required this.tileBg,
    required this.tileFg,
    required this.title,
    required this.body,
    this.extra,
    required this.primary,
    required this.secondary,
    this.centered = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: tileBg,
            borderRadius: KuberShape.largeR,
          ),
          child: Icon(tileIcon, size: 28, color: tileFg),
        ),
        const SizedBox(height: KuberSpace.lg),
        Text(
          title,
          style: theme.textTheme.headlineMedium!.copyWith(color: cs.onSurface),
        ),
        const SizedBox(height: KuberSpace.md),
        Text(
          body,
          style: theme.textTheme.bodyLarge!.copyWith(
            color: cs.onSurfaceVariant,
          ),
        ),
        if (extra != null) ...[const SizedBox(height: KuberSpace.lg), extra!],
      ],
    );
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          KuberSpace.screenMargin,
          KuberSpace.sm,
          KuberSpace.screenMargin,
          KuberSpace.lg,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: centered
                  ? Center(child: SingleChildScrollView(child: content))
                  : SingleChildScrollView(child: content),
            ),
            const SizedBox(height: KuberSpace.md),
            primary,
            const SizedBox(height: KuberSpace.sm),
            Center(child: secondary),
          ],
        ),
      ),
    );
  }
}

/// Ask: three grouped value rows, then the read-only note.
class _AskDetails extends StatelessWidget {
  const _AskDetails();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KuberGroup(
          children: [
            KuberListRow(
              leading: KuberIconTile(icon: Icons.account_balance_outlined),
              title: 'HDFC, SBI, ICICI, Axis, Kotak + 15 more',
              subtitle: 'All major Indian banks and UPI senders.',
              subtitleLines: 2,
            ),
            KuberListRow(
              leading: KuberIconTile(icon: Icons.auto_fix_high_rounded),
              title: 'Learns your accounts',
              subtitle:
                  'After 3 imports from the same sender, the account auto-fills.',
              subtitleLines: 2,
            ),
            KuberListRow(
              leading: KuberIconTile(icon: Icons.block_rounded),
              title: 'OTPs are never read',
              subtitle:
                  'Messages containing OTP or verification codes are '
                  'skipped before parsing.',
              subtitleLines: 2,
            ),
          ],
        ),
        const SizedBox(height: KuberSpace.md),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lock_outline_rounded,
              size: 16,
              color: cs.onSurfaceVariant,
            ),
            const SizedBox(width: KuberSpace.sm),
            Expanded(
              child: Text(
                'Read-only access. Nothing is stored or transmitted without '
                'your approval.',
                style: theme.textTheme.bodySmall!.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Blocked: where to find the toggle, as a breadcrumb card.
class _SettingsHint extends StatelessWidget {
  const _SettingsHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    Widget crumb(String t, {bool last = false}) => Text(
      t,
      style: (last ? theme.textTheme.labelLarge! : theme.textTheme.bodyMedium!)
          .copyWith(color: last ? cs.onSurface : cs.onSurfaceVariant),
    );
    Widget chevron() => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Icon(
        Icons.chevron_right_rounded,
        size: 16,
        color: cs.onSurfaceVariant,
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const KuberSectionHeader(title: 'What to look for in Settings'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: KuberSpace.lg,
            vertical: KuberSpace.md,
          ),
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: KuberShape.largeR,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Wrap(
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              crumb('Apps'),
              chevron(),
              crumb('Kuber'),
              chevron(),
              crumb('Permissions'),
              chevron(),
              crumb('SMS', last: true),
            ],
          ),
        ),
      ],
    );
  }
}
