import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/utils/supported_locales.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_option_card.dart';
import '../../settings/providers/data_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/widgets/language_picker_bottom_sheet.dart';
import '../widgets/onboarding_entrance.dart';

enum StartJob { restore, csv }

/// First page of a fresh install: language, then restore a backup, import a
/// CSV, or Start fresh (the button is in the flow's nav bar).
class OnboardingStartPage extends ConsumerWidget {
  final StartJob? job;
  final StartJob? failed;
  final String fileName;
  final VoidCallback onRestore;
  final VoidCallback onImportCsv;
  final VoidCallback onCancelImport;
  final ValueChanged<Locale> onLocaleChanged;

  const OnboardingStartPage({
    super.key,
    required this.onRestore,
    required this.onImportCsv,
    required this.onCancelImport,
    required this.onLocaleChanged,
    this.job,
    this.failed,
    this.fileName = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final locale = ref.watch(localeProvider);
    final lang = kSupportedLanguages.firstWhere(
      (x) => x.locale.languageCode == locale.languageCode,
      orElse: () => kSupportedLanguages.first,
    );
    final (done, total, label) = ref.watch(
      dataControllerProvider.select((s) => (s.progressDone, s.progressTotal, s.progressLabel)),
    );
    final fmt = ref.watch(formatterProvider);
    String count(int n) => fmt.formatNumber(n);
    final progress = total == 0 ? 0.0 : done / total;
    KuberOptionState stateOf(StartJob me) {
      if (job == me) return KuberOptionState.busy;
      if (job != null) return KuberOptionState.disabled;
      return failed == me ? KuberOptionState.failed : KuberOptionState.idle;
    }

    final restore = stateOf(StartJob.restore);
    final csv = stateOf(StartJob.csv);

    return _LocaleFade(
      locale: locale,
      // Fills the page, and scrolls when the largest font makes it taller
      // (no intrinsic sizing: the cards' AnimatedSize can't report one).
      child: LayoutBuilder(
        builder: (context, box) => SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: box.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  height: 56,
                  padding: const EdgeInsets.symmetric(horizontal: KuberSpace.lg),
                  alignment: AlignmentDirectional.centerEnd,
                  child: KuberLanguageButton(
                    label: lang.nativeName,
                    locale: lang.locale,
                    enabled: job == null,
                    onTap: () => showWelcomeLanguageSheet(
                      context: context,
                      currentLocale: locale,
                      onSelected: (next) {
                        ref.read(settingsProvider.notifier).setLocale(next);
                        onLocaleChanged(next);
                      },
                    ),
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.all(KuberSpace.screenMargin),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const OnboardingEntrance(
                          duration: Duration(milliseconds: 420),
                          beginOffset: Offset.zero,
                          scale: 0.8,
                          curve: Easing.emphasizedDecelerate,
                          child: KuberIconTile(
                            icon: Icons.currency_rupee_rounded,
                            size: 96,
                            glyph: 54,
                            radius: 28,
                            tone: KuberTone.primary,
                          ),
                        ),
                        const SizedBox(height: KuberSpace.md),
                        Text('Kuber', style: theme.textTheme.displaySmall!.copyWith(color: cs.onSurface)),
                        const SizedBox(height: KuberSpace.md),
                        OnboardingEntrance(
                          delay: const Duration(milliseconds: 150),
                          duration: KuberMotion.fast,
                          beginOffset: Offset.zero,
                          child: Text(
                            l.obStartTagline,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge!.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ),
                      ],
                    ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: KuberSpace.screenMargin),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OnboardingEntrance(
                        delay: const Duration(milliseconds: 150),
                        duration: const Duration(milliseconds: 250),
                        beginOffset: Offset.zero,
                        rise: 16,
                        child: KuberOptionCard(
                          icon: Icons.settings_backup_restore_rounded,
                          title: switch (restore) {
                            KuberOptionState.busy => l.obRestoreBusy,
                            KuberOptionState.failed => l.obRestoreFailed,
                            _ => l.obStartRestore,
                          },
                          subtitle: switch (restore) {
                            KuberOptionState.busy => fileName,
                            KuberOptionState.failed => l.obRestoreFailedSub,
                            _ => l.obStartRestoreSub,
                          },
                          state: restore,
                          onTap: onRestore,
                          progress: progress,
                          step: total == 0
                              ? null
                              : label == 'transactions'
                                  ? l.obRestoreStepTxns(count(done), count(total))
                                  : l.obRestoreStepItems(count(done), count(total)),
                          retryLabel: l.obRestoreRetry,
                          onRetry: onRestore,
                          otherLabel: l.obRestoreOtherFile,
                          onOther: onRestore,
                        ),
                      ),
                      const SizedBox(height: KuberSpace.md),
                      OnboardingEntrance(
                        delay: const Duration(milliseconds: 190),
                        duration: const Duration(milliseconds: 250),
                        beginOffset: Offset.zero,
                        rise: 16,
                        child: KuberOptionCard(
                          icon: Icons.upload_file_rounded,
                          title: switch (csv) {
                            KuberOptionState.busy => l.obCsvBusy,
                            KuberOptionState.failed => l.obCsvFailed,
                            _ => l.obStartCsv,
                          },
                          subtitle: switch (csv) {
                            KuberOptionState.busy => fileName,
                            KuberOptionState.failed => l.obCsvFailedSub,
                            _ => l.obStartCsvSub,
                          },
                          state: csv,
                          onTap: onImportCsv,
                          progress: progress,
                          step: total == 0 ? null : l.obCsvStep(count(done), count(total)),
                          cancelLabel: l.cancelLabel,
                          onCancel: onCancelImport,
                          retryLabel: l.obRestoreRetry,
                          onRetry: onImportCsv,
                          otherLabel: l.obRestoreOtherFile,
                          onOther: onImportCsv,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Fades the page in on a language change, so the new strings don't jump in.
class _LocaleFade extends StatefulWidget {
  final Locale locale;
  final Widget child;
  const _LocaleFade({required this.locale, required this.child});

  @override
  State<_LocaleFade> createState() => _LocaleFadeState();
}

class _LocaleFadeState extends State<_LocaleFade> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: KuberMotion.fast, value: 1);

  @override
  void didUpdateWidget(_LocaleFade old) {
    super.didUpdateWidget(old);
    if (old.locale != widget.locale) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(opacity: _c, child: widget.child);
}
