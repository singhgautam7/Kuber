import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_page_header.dart';
import '../../../core/constants/info_constants.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../providers/backup_provider.dart';
import '../utils/backup_uri_formatter.dart';

class AutomaticBackupsScreen extends ConsumerWidget {
  const AutomaticBackupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(backupSettingsProvider);
    return Scaffold(
      backgroundColor: cs.surface,
      body: settings.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text(context.l10n.errorWithDetails(error.toString()))),
        data: (s) => CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KuberAppBar(
                showBack: true,
                showHome: true,
                title: '',
                infoConfig: InfoConstants.automaticBackups,
              ),
            ),
            SliverToBoxAdapter(
              child: KuberPageHeader(
                title: context.l10n.backupsTitle,
                description: context.l10n.backupsSubtitle,
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(20, 0, 20, 40 + systemNavBarInset(context)),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _sectionLabel(context, context.l10n.statusSectionLabel),
                  _StatusBlock(settings: s),
                  _sectionLabel(context, context.l10n.configurationLabel),
                  _MasterToggle(
                    value: s.enabled,
                    onChanged: (value) => ref
                        .read(backupSettingsProvider.notifier)
                        .setEnabled(value),
                  ),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 220),
                    curve: Curves.easeOutCubic,
                    alignment: Alignment.topCenter,
                    child: s.enabled
                        ? _ConfigGroup(settings: s)
                        : const SizedBox(width: double.infinity),
                  ),
                  _sectionLabel(context, context.l10n.actionsLabel),
                  AppButton(
                    label: context.l10n.backupNow,
                    icon: Icons.cloud_upload_outlined,
                    type: AppButtonType.outline,
                    fullWidth: true,
                    onPressed: s.enabled && s.folderPath != null && !s.backupJustCompleted
                        ? () async {
                              final (success, message) = await ref
                                  .read(backupSettingsProvider.notifier)
                                  .backupNow();
                              if (!context.mounted) return;
                              showKuberSnackBar(
                                context,
                                message,
                                isError: !success,
                              );
                            }
                        : null,
                  ),
                  if (s.backupJustCompleted)
                    Padding(
                      padding: const EdgeInsets.only(top: KuberSpacing.sm),
                      child: Text(
                        context.l10n.alreadyBackedUpToday,
                        style: localeFont(
                          fontSize: 12,
                          color: cs.onSurfaceVariant,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Text(
        text.toUpperCase(),
        style: localeFont(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
          color: cs.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _StatusBlock extends ConsumerWidget {
  final BackupSettings settings;
  const _StatusBlock({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    switch (settings.status) {
      case BackupStatus.failed:
        return _StatusCard(
          icon: Icons.error_outline_rounded,
          tint: cs.error,
          tintBg: cs.error.withValues(alpha: 0.10),
          border: cs.error.withValues(alpha: 0.32),
          title: context.l10n.lastBackupFailed,
          titleColor: cs.error,
          description:
              settings.failureReason ??
              context.l10n.backupFolderErrorDesc,
          timestamp: settings.lastAttemptLabel == null
              ? null
              : context.l10n.attemptedOn(settings.lastAttemptLabel!),
          action: (
            context.l10n.chooseNewFolder,
            Icons.folder_open_rounded,
            () => ref.read(backupSettingsProvider.notifier).pickFolder(),
          ),
        );
      case BackupStatus.succeeded:
        return _StatusCard(
          icon: Icons.check_circle_outline_rounded,
          tint: cs.tertiary,
          tintBg: cs.tertiary.withValues(alpha: 0.10),
          border: cs.tertiary.withValues(alpha: 0.28),
          title: settings.lastAttemptLabel == null
              ? context.l10n.backedUp
              : context.l10n.backedUpOn(settings.lastAttemptLabel!),
          titleColor: cs.tertiary,
          description:
              context.l10n.lastCopySaved('${settings.retention}'),
        );
      case BackupStatus.neverConfigured:
        return _StatusCard(
          icon: Icons.backup_outlined,
          tint: cs.primary,
          tintBg: cs.primary.withValues(alpha: 0.10),
          border: cs.outline,
          title: context.l10n.neverLoseData,
          titleColor: cs.onSurface,
          description:
              context.l10n.neverLoseDataDesc,
        );
    }
  }
}

class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color tint;
  final Color tintBg;
  final Color border;
  final Color titleColor;
  final String title;
  final String description;
  final String? timestamp;
  final (String, IconData, VoidCallback)? action;

  const _StatusCard({
    required this.icon,
    required this.tint,
    required this.tintBg,
    required this.border,
    required this.title,
    required this.titleColor,
    required this.description,
    this.timestamp,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: tintBg,
        borderRadius: BorderRadius.circular(KuberRadius.lg),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: tint.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(KuberRadius.md),
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 22, color: tint),
          ),
          const SizedBox(width: KuberSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: localeFont(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: titleColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: localeFont(
                    fontSize: 12.5,
                    height: 1.45,
                    color: cs.onSurfaceVariant,
                  ),
                ),
                if (action != null) ...[
                  const SizedBox(height: 12),
                  GestureDetector(
                    onTap: action!.$3,
                    child: Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: tint,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(action!.$2, size: 17, color: Colors.white),
                          const SizedBox(width: 7),
                          Text(
                            action!.$1,
                            style: localeFont(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                if (timestamp != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    timestamp!.toUpperCase(),
                    style: localeFont(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MasterToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _MasterToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.automaticBackups,
                  style: localeFont(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.saveCopyOnSchedule,
                  style: localeFont(
                    fontSize: 12.5,
                    color: cs.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

class _ConfigGroup extends ConsumerWidget {
  final BackupSettings settings;
  const _ConfigGroup({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _label(cs, context.l10n.frequencyLabel),
        SegmentedButton<BackupFrequency>(
          segments: [
            ButtonSegment(value: BackupFrequency.daily, label: Text(context.l10n.freqDaily)),
            ButtonSegment(value: BackupFrequency.weekly, label: Text(context.l10n.freqWeekly)),
            ButtonSegment(
              value: BackupFrequency.monthly,
              label: Text(context.l10n.freqMonthly),
            ),
          ],
          selected: {settings.frequency},
          showSelectedIcon: false,
          onSelectionChanged: (value) => ref
              .read(backupSettingsProvider.notifier)
              .setFrequency(value.first),
        ),
        _label(cs, context.l10n.keepLast),
        Row(
          children: [
            for (final n in const [1, 5, 10]) ...[
              Expanded(
                child: _RetentionPill(
                  count: n,
                  selected: settings.retention == n,
                  onTap: () =>
                      ref.read(backupSettingsProvider.notifier).setRetention(n),
                ),
              ),
              if (n != 10) const SizedBox(width: KuberSpacing.sm),
            ],
          ],
        ),
        _label(cs, context.l10n.backupFolder),
        GestureDetector(
          onTap: () => ref.read(backupSettingsProvider.notifier).pickFolder(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: cs.surfaceContainer,
              borderRadius: BorderRadius.circular(KuberRadius.md),
              border: Border.all(color: cs.outline),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_outlined, size: 24, color: cs.primary),
                const SizedBox(width: KuberSpacing.md),
                Expanded(
                  child: Text(
                    formatBackupFolderUri(settings.folderPath),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                      fontSize: 14.5,
                      fontWeight: settings.folderPath == null
                          ? FontWeight.w500
                          : FontWeight.w600,
                      color: settings.folderPath == null
                          ? cs.onSurfaceVariant
                          : cs.onSurface,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _label(ColorScheme cs, String text) => Padding(
    padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
    child: Text(
      text.toUpperCase(),
      style: localeFont(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.2,
        color: cs.onSurfaceVariant,
      ),
    ),
  );

}

class _RetentionPill extends StatelessWidget {
  final int count;
  final bool selected;
  final VoidCallback onTap;

  const _RetentionPill({
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? cs.primaryContainer : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: selected ? cs.primary.withValues(alpha: 0.45) : cs.outline,
          ),
        ),
        child: Text(
          '$count backup${count == 1 ? '' : 's'}',
          style: localeFont(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}