import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import '../../../core/background/background_reporter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../core/constants/info_constants.dart';
import '../../pro/feature_gates/gate_sheet_backups.dart';
import '../../pro/feature_gates/pro_gate.dart';
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
        // Keep the current content on reload (e.g. after toggling a setting)
        // instead of flashing a full-screen spinner.
        skipLoadingOnReload: true,
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Text(context.l10n.errorWithDetails(error.toString())),
        ),
        data: (s) => CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: KuberAppBar(
                showBack: true,
                title: context.l10n.backupsTitle.replaceAll('\n', ' '),
                infoConfig: InfoConstants.automaticBackups,
              ),
            ),

            SliverPadding(
              padding: EdgeInsets.fromLTRB(
                20,
                0,
                20,
                40 + systemNavBarInset(context),
              ),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _sectionLabel(context, context.l10n.statusSectionLabel),
                  _StatusBlock(settings: s),
                  _sectionLabel(context, context.l10n.configurationLabel),
                  _MasterToggle(
                    value: s.enabled,
                    onChanged: (value) {
                      // Automatic Backups is a Kuber Pro feature. Gate only the
                      // act of turning it on; disabling is always allowed.
                      if (value &&
                          !proGate(context, ref, showBackupsGateSheet)) {
                        return;
                      }
                      ref
                          .read(backupSettingsProvider.notifier)
                          .setEnabled(value);
                    },
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
                  // Primary action button; renders in its disabled style when
                  // the user can't back up yet (off, no folder, or already
                  // backed up today).
                  AppButton(
                    label: context.l10n.backupNow,
                    icon: Icons.cloud_upload_outlined,
                    type: AppButtonType.primary,
                    fullWidth: true,
                    onPressed:
                        s.enabled &&
                            s.folderPath != null &&
                            !s.backupJustCompleted
                        ? () {
                            // Progress and result through the one
                            // background reporter (D3).
                            final l = context.l10n;
                            BackgroundReporter.instance
                                .run<(bool, String)>(
                                  l.bgStepBackup,
                                  (_) => ref
                                      .read(backupSettingsProvider.notifier)
                                      .backupNow(),
                                  outcome: (r) => r.$1
                                      ? BgOutcome(l.bgBackupSaved)
                                      : BgOutcome(l.bgFailBackup,
                                          error: true, details: r.$2),
                                )
                                .ignore();
                          }
                        : null,
                  ),
                  // Helper line under the button: a real backup failure is an
                  // error (red); "already backed up today" is just an
                  // informational note (muted).
                  if (s.status == BackupStatus.failed &&
                      s.failureReason != null)
                    _ButtonHelperText(text: s.failureReason!, isError: true)
                  else if (s.backupJustCompleted)
                    _ButtonHelperText(
                      text: context.l10n.alreadyBackedUpToday,
                      isError: false,
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
          fontWeight: FontWeight.w600,
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
    final money = context.kuberMoney;
    final l = context.l10n;

    // Board 3.12b chips: when the next run is due and where copies go.
    final chips = <(IconData, String)>[
      if (settings.nextBackupAt case final next?)
        (
          Icons.event_outlined,
          next.isAfter(DateUtils.dateOnly(DateTime.now()))
              ? l.nextBackupOn(DateFormatter.full(next, format: 'MMM d'))
              : l.nextBackupNextOpen,
        ),
      if (settings.folderPath != null)
        (
          Icons.folder_outlined,
          formatBackupFolderUri(settings.folderPath).split(' / ').last,
        ),
    ];

    switch (settings.status) {
      case BackupStatus.failed:
        return _StatusCard(
          icon: Icons.error_rounded,
          bg: cs.errorContainer,
          fg: cs.onErrorContainer,
          title: l.lastBackupFailed,
          description: settings.failureReason ?? l.backupFolderErrorDesc,
          timestamp: settings.lastAttemptLabel == null
              ? null
              : l.attemptedOn(settings.lastAttemptLabel!),
          action: AppButton(
            label: l.chooseNewFolder,
            icon: Icons.folder_open_rounded,
            type: AppButtonType.danger,
            filled: true,
            height: 40,
            onPressed: () =>
                ref.read(backupSettingsProvider.notifier).pickFolder(),
          ),
        );
      case BackupStatus.succeeded:
        return _StatusCard(
          icon: Icons.check_circle_rounded,
          bg: money.incomeContainer,
          fg: money.onIncomeContainer,
          title: settings.lastAttemptLabel == null
              ? l.backedUp
              : l.backedUpOn(settings.lastAttemptLabel!),
          description: l.lastCopySaved('${settings.retention}'),
          chips: chips,
        );
      case BackupStatus.ready:
        // On with a folder chosen, no backup run yet.
        return _StatusCard(
          icon: Icons.cloud_done_rounded,
          bg: money.incomeContainer,
          fg: money.onIncomeContainer,
          title: l.backupsAreOn,
          description: l.backupsAreOnDesc,
          chips: chips,
        );
      case BackupStatus.neverConfigured:
        return _StatusCard(
          icon: Icons.backup_rounded,
          bg: cs.secondaryContainer,
          fg: cs.onSecondaryContainer,
          title: l.neverLoseData,
          description: l.neverLoseDataDesc,
        );
    }
  }
}

/// Small centered helper line rendered under the "Back up now" button. Red for
/// a real error, muted for an informational note.
class _ButtonHelperText extends StatelessWidget {
  final String text;
  final bool isError;
  const _ButtonHelperText({required this.text, required this.isError});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: KuberSpace.sm),
      child: Text(
        text,
        style: localeFont(
          fontSize: 12,
          color: isError ? cs.error : cs.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Board 3.12b status card: one tonal container answers "am I safe?". Filled
/// icon in a 48 tile, titleLarge, bodyMedium, then optional chips, a timestamp
/// and an action, all in the container's on-colour.
class _StatusCard extends StatelessWidget {
  final IconData icon;
  final Color bg;
  final Color fg;
  final String title;
  final String description;
  final List<(IconData, String)> chips;
  final String? timestamp;
  final Widget? action;

  const _StatusCard({
    required this.icon,
    required this.bg,
    required this.fg,
    required this.title,
    required this.description,
    this.chips = const [],
    this.timestamp,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpace.cardPaddingHero),
      decoration: BoxDecoration(color: bg, borderRadius: KuberShape.cardR),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: fg.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(KuberShape.large),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 26, color: fg),
              ),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: tt.titleLarge!.copyWith(color: fg)),
                    const SizedBox(height: KuberSpace.xs),
                    Text(
                      description,
                      style: tt.bodyMedium!.copyWith(color: fg),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: KuberSpace.md),
            Wrap(
              spacing: KuberSpace.sm,
              runSpacing: KuberSpace.sm,
              children: [
                for (final (chipIcon, label) in chips)
                  Container(
                    height: 28,
                    padding: const EdgeInsets.only(left: 8, right: 10),
                    decoration: BoxDecoration(
                      color: fg.withValues(alpha: 0.10),
                      borderRadius: KuberShape.fullR,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(chipIcon, size: 16, color: fg),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: tt.labelMedium!.copyWith(color: fg),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
          if (timestamp != null) ...[
            const SizedBox(height: KuberSpace.md),
            Text(
              timestamp!.toUpperCase(),
              style: tt.labelMedium!.copyWith(color: fg, letterSpacing: 0.6),
            ),
          ],
          if (action != null) ...[
            const SizedBox(height: KuberSpace.md),
            action!,
          ],
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
      padding: const EdgeInsets.all(KuberSpace.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.automaticBackups,
                  style: localeFont(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  context.l10n.saveCopyOnSchedule,
                  style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
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
            ButtonSegment(
              value: BackupFrequency.daily,
              label: Text(context.l10n.freqDaily),
            ),
            ButtonSegment(
              value: BackupFrequency.weekly,
              label: Text(context.l10n.freqWeekly),
            ),
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
              if (n != 10) const SizedBox(width: KuberSpace.sm),
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
              borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Row(
              children: [
                Icon(Icons.folder_outlined, size: 24, color: cs.primary),
                const SizedBox(width: KuberSpace.md),
                Expanded(
                  child: Text(
                    formatBackupFolderUri(settings.folderPath),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: localeFont(
                      fontSize: 14,
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
        fontWeight: FontWeight.w600,
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
          color: selected ? cs.secondaryContainer : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.45)
                : cs.outlineVariant,
          ),
        ),
        child: Text(
          '$count backup${count == 1 ? '' : 's'}',
          style: localeFont(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: selected ? cs.primary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
