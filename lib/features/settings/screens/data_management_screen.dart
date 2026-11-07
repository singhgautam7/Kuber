import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';

import '../../../core/services/mock_data_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../providers/data_provider.dart';
import '../../backups/providers/backup_provider.dart';
import '../../kuber_cards/widgets/imported_cards_prompt.dart';
import 'settings_pages.dart' show backupAgo;
import '../widgets/data_action_widgets.dart';
import '../widgets/settings_anchor.dart';
import '../widgets/settings_section.dart';
import '../widgets/data_export_bottom_sheet.dart';
import '../widgets/data_import_bottom_sheet.dart';

String _getMockDataTitle(String lang) {
  switch (lang) {
    case 'hi':
      return 'प्रयोगात्मक डेटा उत्पन्न करें';
    case 'kn':
      return 'ಅಣಕು ಡೇಟಾವನ್ನು ರಚಿಸಿ';
    case 'mr':
      return 'प्रात्यक्षिक डेटा तयार करा';
    case 'pa':
      return 'ਨਕਲੀ ਡੇਟਾ ਤਿਆਰ ਕਰੋ';
    case 'bn':
      return 'মক ডেটা তৈরি করুন';
    case 'te':
      return 'మాక్ డేటాను సృష్టించండి';
    case 'ta':
      return 'போலி தரவை உருவாக்கவும்';
    case 'ml':
      return 'മോക്ക് ഡാറ്റ സൃഷ്ടിക്കുക';
    default:
      return 'Generate Mock Data';
  }
}

String _getMockDataDesc(String lang) {
  switch (lang) {
    case 'hi':
      return 'परीक्षण के लिए ऐप में वास्तविक दिखने वाले नमूना डेटा को भरें।';
    case 'kn':
      return 'ಪರೀಕ್ಷೆಗಾಗಿ ಆಪ್‌ನಲ್ಲಿ ನೈಜವಾಗಿ ಕಾಣುವ ಮಾದರಿ ಡೇಟಾವನ್ನು ಭರ್ತಿ ಮಾಡಿ.';
    case 'mr':
      return 'चाचणीसाठी अॅपमध्ये वास्तववादी नमुना डेटा भरा.';
    case 'pa':
      return 'ਟੈਸਟਿੰਗ ਲਈ ਐਪ ਵਿੱਚ ਅਸਲੀ ਵਰਗਾ ਨਮੂਨਾ ਡੇਟਾ ਭਰੋ।';
    case 'bn':
      return 'পরীক্ষার জন্য অ্যাপে বাস্তবসম্মত নমুনা ডেটা পূরণ করুন।';
    case 'te':
      return 'పరీక్ష కోసం యాప్‌లో వాస్తవిక నమూనా డేటాను పూరించండి.';
    case 'ta':
      return 'சோதனைக்காக செயலியில் யதார்த்தமான மாதிரி தரவை நிரப்பவும்.';
    case 'ml':
      return 'പരിശോധനയ്ക്കായി ആപ്പിൽ യഥാർത്ഥമെന്ന് തോന്നുന്ന മാതൃകാ ഡാറ്റ പൂരിപ്പിക്കുക.';
    default:
      return 'Populate the app with realistic sample data for testing.';
  }
}

String _getMockDataConfirmTitle(String lang) {
  switch (lang) {
    case 'hi':
      return 'प्रयोगात्मक डेटा उत्पन्न करें?';
    case 'kn':
      return 'ಅಣಕು ಡೇಟಾವನ್ನು ರಚಿಸಬೇಕೆ?';
    case 'mr':
      return 'प्रात्यक्षिक डेटा तयार करायचा?';
    case 'pa':
      return 'ਨਕਲੀ ਡੇਟਾ ਤਿਆਰ ਕਰਨਾ ਹੈ?';
    case 'bn':
      return 'মক ডেটা তৈরি করবেন?';
    case 'te':
      return 'మాక్ డేటాను సృష్టించాలా?';
    case 'ta':
      return 'போலி தரவை உருவாக்கவா?';
    case 'ml':
      return 'മോക്ക് ഡാറ്റ സൃഷ്ടിക്കണോ?';
    default:
      return 'Generate Mock Data?';
  }
}

String _getMockDataConfirmDesc(String lang) {
  switch (lang) {
    case 'hi':
      return 'सभी मौजूदा डेटा स्थायी रूप से हटा दिए जाएंगे और उनके स्थान पर नमूना डेटा डाल दिया जाएगा।';
    case 'kn':
      return 'ಅಸ್तिತ್ವದಲ್ಲಿರುವ ಎಲ್ಲಾ ಡೇಟಾವನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಲಾಗುತ್ತದೆ ಮತ್ತು ಮಾದರಿ ಡೇಟಾದೊಂದಿಗೆ ಬದಲಾಯಿಸಲಾಗುತ್ತದೆ.';
    case 'mr':
      return 'सर्व विद्यमान डेटा कायमचा हटविला जाईल आणि नमुना डेटासह पुनर्स्थित केला जाईल.';
    case 'pa':
      return 'ਸਾਰਾ ਮੌਜੂਦਾ ਡੇਟਾ ਸਥਾਈ ਤੌਰ \'ਤੇ ਮਿਟਾ ਦਿੱਤਾ ਜਾਵੇਗਾ ਅਤੇ ਨਮੂਨੇ ਦੇ ਡੇਟਾ ਨਾਲ ਬਦਲ ਦਿੱਤਾ ਜਾਵੇਗਾ।';
    case 'bn':
      return 'বিদ্যমান সমস্ত ডেটা স্থায়ীভাবে মুছে ফেলা হবে এবং নমুনা ডেটা দিয়ে প্রতিস্থাপন করা হবে।';
    case 'te':
      return 'ఉన్న డేటా అంతా శాశ్వతంగా తొలగించబడుతుంది మరియు నమూనా డేటాతో భర్తీ చేయబడుతుంది.';
    case 'ta':
      return 'தற்போதுள்ள அனைத்து தரவும் நிரந்தரமாக நீக்கப்பட்டு, மாதிரி தரவுகளால் மாற்றப்படும்.';
    case 'ml':
      return 'നിലവിലുള്ള എല്ലാ ഡാറ്റയും ശാശ്വതമായി ഇല്ലാതാക്കപ്പെടുകയും മാതൃകാ ഡാറ്റ ഉപയോഗിച്ച് മാറ്റപ്പെടുകയും ചെയ്യും.';
    default:
      return 'All existing data will be permanently deleted and replaced with sample data.';
  }
}

String _getMockDataConfirmLabel(String lang) {
  switch (lang) {
    case 'hi':
      return 'उत्पन्न करें';
    case 'kn':
      return 'ರಚಿಸಿ';
    case 'mr':
      return 'तयार करा';
    case 'pa':
      return 'ਤਿਆਰ ਕਰੋ';
    case 'bn':
      return 'তৈরি করুন';
    case 'te':
      return 'సృష్టించు';
    case 'ta':
      return 'உருவாக்கு';
    case 'ml':
      return 'സൃഷ്ടിക്കുക';
    default:
      return 'Generate';
  }
}

String _getBackupFailedLabel(String lang) {
  switch (lang) {
    case 'hi':
      return 'पिछला बैकअप विफल रहा';
    case 'kn':
      return 'ಕೊನೆಯ ಬ್ಯಾಕಪ್ ವಿಫಲವಾಗಿದೆ';
    case 'mr':
      return 'शेवटचा बॅकअप अयशस्वी झाला';
    case 'pa':
      return 'ਆਖਰੀ ਬੈਕਅੱਪ ਅਸਫਲ ਰਿਹਾ';
    case 'bn':
      return 'শেষ ব্যাকআপ ব্যর্থ হয়েছে';
    case 'te':
      return 'చివరి బ్యాకప్ విఫలమైంది';
    case 'ta':
      return 'கடைசி காப்புப்பிரதி தோல்வியடைந்தது';
    case 'ml':
      return 'അവസാന ബാക്കപ്പ് പരാജയപ്പെട്ടു';
    default:
      return 'Last backup failed';
  }
}

String _getProcessingLabel(String lang) {
  switch (lang) {
    case 'hi':
      return 'प्रसंस्करण हो रहा है…';
    case 'kn':
      return 'ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲಾಗುತ್ತಿದೆ...';
    case 'mr':
      return 'प्रक्रिया सुरू आहे…';
    case 'pa':
      return 'ਕਾਰਵਾਈ ਚੱਲ ਰਹੀ ਹੈ…';
    case 'bn':
      return 'প্রক্রিয়াকরণ করা হচ্ছে…';
    case 'te':
      return 'ప్రక్రియ జరుగుతోంది…';
    case 'ta':
      return 'செயலாக்கப்படுகிறது…';
    case 'ml':
      return 'പ്രോസസ്സ് ചെയ്യുന്നു...';
    default:
      return 'Processing…';
  }
}

class DataManagementScreen extends ConsumerWidget {
  final String? highlight;
  const DataManagementScreen({super.key, this.highlight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final state = ref.watch(dataControllerProvider);
    final backupSettings = ref.watch(backupSettingsProvider).valueOrNull;
    final backupFailed = backupSettings?.status == BackupStatus.failed;
    final lang = AppLocale.current.languageCode;

    ref.listen(dataControllerProvider, (previous, next) {
      if (next.status == DataOpStatus.success && next.message != null) {
        showKuberSnackBar(context, next.message!);
        final lockedCards = next.lockedCardsFound;
        ref.read(dataControllerProvider.notifier).reset();
        // A JSON restore that carried encrypted cards prompts for the backup's
        // PIN so they can be unlocked and kept (or discarded). See import-flow.md.
        if (lockedCards) {
          showImportedCardsPrompt(context);
        }
      } else if (next.status == DataOpStatus.error && next.message != null) {
        showKuberSnackBar(context, next.message!, isError: true);
        ref.read(dataControllerProvider.notifier).reset();
      }
    });

    return Stack(
      children: [
        SettingsPageFrame(
          title: context.l10n.setGroupData,
          highlight: highlight,
          children: [
            const _LastBackupCard(),
            const SizedBox(height: KuberSpace.sectionGap),
            SettingsBlock(
              title: l.setSecBackup,
              children: [
                SettingsAnchor('backup', child: SettingsTile(
                  icon: backupFailed ? Icons.warning_amber_rounded : Icons.event_repeat_rounded,
                  label: l.setAutoBackups,
                  subtitle: backupFailed ? _getBackupFailedLabel(lang) : _autoSub(l, backupSettings),
                  onTap: () => context.push('/more/data/automatic-backups'),
                  trailing: _value(context, backupSettings?.enabled == true ? l.setOn : l.setOff),
                )),
                SettingsAnchor('restore-data', child: SettingsTile(
                  icon: Icons.settings_backup_restore_rounded,
                  label: l.obStartRestore,
                  subtitle: l.setRestoreSub,
                  onTap: () => showDataImportBottomSheet(context, json: true),
                  trailing: const KuberChevron(),
                )),
              ],
            ),
            SettingsBlock(
              title: l.setSecImport,
              children: [
                SettingsAnchor('import', child: SettingsTile(
                  icon: Icons.upload_file_rounded,
                  label: l.obStartCsv,
                  subtitle: l.setImportCsvSub,
                  onTap: () => showDataImportBottomSheet(context),
                  trailing: const KuberChevron(),
                )),
                SettingsAnchor('importKuber', child: SettingsTile(
                  icon: Icons.download_rounded,
                  label: l.setImportKuber,
                  subtitle: l.setImportKuberSub,
                  onTap: () => showDataImportBottomSheet(context, json: true),
                  trailing: const KuberChevron(),
                )),
                SettingsAnchor('export', child: SettingsTile(
                  icon: Icons.ios_share_rounded,
                  label: l.setExport,
                  subtitle: l.setExportSub,
                  onTap: () => showDataExportBottomSheet(context),
                  trailing: const KuberChevron(),
                )),
              ],
            ),
            SettingsBlock(
              title: l.setSecDanger,
              children: [
                SettingsAnchor('mockData', child: SettingsTile(
                  icon: Icons.science_outlined,
                  label: _getMockDataTitle(lang),
                  subtitle: _getMockDataDesc(lang),
                  onTap: () => _confirmMockData(context, ref),
                  trailing: const KuberChevron(),
                )),
                SettingsAnchor('clear', child: SettingsTile(
                  icon: Icons.delete_forever_rounded,
                  label: l.setClear,
                  subtitle: l.setClearSub,
                  destructive: true,
                  onTap: () => _confirmClearData(context, ref),
                  trailing: const KuberChevron(),
                )),
              ],
            ),
          ],
        ),
        if (state.status == DataOpStatus.loading)
          DataLoadingOverlay(
            message: state.loadingMessage ?? _getProcessingLabel(lang),
          ),
      ],
    );
  }

  Widget _value(BuildContext context, String text) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text, style: theme.textTheme.bodyMedium!.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(width: KuberSpace.lg),
        const KuberChevron(),
      ],
    );
  }

  /// "Weekly · Downloads/Kuber".
  String _autoSub(AppLocalizations l, BackupSettings? s) {
    if (s == null || !s.enabled) return l.backupDesc;
    final often = switch (s.frequency) {
      BackupFrequency.daily => l.freqDaily,
      BackupFrequency.weekly => l.freqWeekly,
      BackupFrequency.monthly => l.freqMonthly,
    };
    return s.folderPath == null ? often : '$often · ${s.folderPath}';
  }

  void _confirmClearData(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmActionSheet(
        icon: Icons.delete_forever_rounded,
        title: context.l10n.clearDataConfirm,
        description: context.l10n.clearDataConfirmBody.replaceAll(
          ' Type DELETE to confirm.',
          '',
        ),
        confirmLabel: context.l10n.clearAllData,
        destructive: true,
        // A full wipe is irreversible, so the sheet's "Clear all" is only the
        // first gate: it opens a second type-to-confirm dialog (like the card
        // delete flow) that requires the exact words "reset all".
        onConfirm: () => _confirmResetAllTyped(context, ref),
      ),
    );
  }

  /// Second, deliberate gate for a full wipe: the user must type the exact
  /// phrase `reset all` before the destructive action runs. Mirrors the
  /// type-the-nickname confirmation used to delete a card.
  void _confirmResetAllTyped(BuildContext context, WidgetRef ref) {
    const phrase = 'reset all';
    final controller = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        final cs = Theme.of(dialogCtx).colorScheme;
        return StatefulBuilder(
          builder: (dialogCtx, setDialog) {
            final canReset = controller.text.trim().toLowerCase() == phrase;
            return AlertDialog(
              title: Text(
                'Reset everything?',
                style: localeFont(fontWeight: FontWeight.w700),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This permanently erases all your data, including your '
                    'encrypted Kuber Cards. This cannot be undone.',
                    style: localeFont(color: cs.onSurfaceVariant, height: 1.45),
                  ),
                  const SizedBox(height: KuberSpace.md),
                  Text(
                    'Type "reset all" to confirm:',
                    style: localeFont(fontSize: 12, color: cs.onSurfaceVariant),
                  ),
                  const SizedBox(height: KuberSpace.sm),
                  TextField(
                    controller: controller,
                    autofocus: true,
                    onChanged: (_) => setDialog(() {}),
                    style: localeFont(color: cs.onSurface),
                    decoration: const InputDecoration(hintText: phrase),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: Text('Cancel', style: localeFont()),
                ),
                AppButton(
                  label: 'Reset all',
                  type: AppButtonType.danger,
                  filled: true,
                  onPressed: canReset
                      ? () {
                          Navigator.pop(dialogCtx);
                          ref
                              .read(dataControllerProvider.notifier)
                              .clearAllData();
                        }
                      : null,
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmMockData(BuildContext context, WidgetRef ref) {
    final lang = AppLocale.current.languageCode;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmActionSheet(
        icon: Icons.science_outlined,
        title: _getMockDataConfirmTitle(lang),
        description:
            '${_getMockDataConfirmDesc(lang)}\n\nKuber Cards PIN: '
            '${MockDataService.mockCardsPin}',
        confirmLabel: _getMockDataConfirmLabel(lang),
        warnDescription: true,
        onConfirm: () =>
            ref.read(dataControllerProvider.notifier).generateMockData(),
      ),
    );
  }
}

/// Top of the page: when the last backup ran, and a way to run one now.
class _LastBackupCard extends ConsumerStatefulWidget {
  const _LastBackupCard();

  @override
  ConsumerState<_LastBackupCard> createState() => _LastBackupCardState();
}

class _LastBackupCardState extends ConsumerState<_LastBackupCard> {
  bool _busy = false;

  Future<void> _backUp(BackupSettings? s) async {
    // Needs a folder, which is picked on the backups page.
    if (s?.folderPath == null) {
      context.push('/more/data/automatic-backups');
      return;
    }
    setState(() => _busy = true);
    final (ok, message) = await ref.read(backupSettingsProvider.notifier).backupNow();
    if (!mounted) return;
    setState(() => _busy = false);
    showKuberSnackBar(context, message, isError: !ok);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final s = ref.watch(backupSettingsProvider).valueOrNull;
    final at = s?.lastBackupAt;
    final failed = s?.status == BackupStatus.failed;
    return KuberCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KuberIconTile(
                icon: failed ? Icons.warning_amber_rounded : Icons.cloud_done_rounded,
                size: 48,
                glyph: 24,
                radius: 14,
                tone: failed ? KuberTone.error : (at == null ? KuberTone.neutral : KuberTone.income),
              ),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l.setLastBackup.toUpperCase(), style: sectionHeaderStyle(context)),
                    Text(
                      at == null ? l.setNoBackupYet : backupAgo(l, at),
                      style: theme.textTheme.headlineSmall!.copyWith(color: cs.onSurface),
                    ),
                    Text(
                      at == null
                          ? l.setNoBackupSub
                          : [
                              DateFormat('EEE d MMM y, h:mm a', l.localeName).format(at),
                              if (s?.folderPath != null) s!.folderPath!,
                            ].join(' · '),
                      style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: KuberSpace.lg),
          AppButton(
            label: l.setBackupNow,
            icon: Icons.backup_outlined,
            fullWidth: true,
            height: 40,
            isLoading: _busy,
            onPressed: () => _backUp(s),
          ),
        ],
      ),
    );
  }
}
