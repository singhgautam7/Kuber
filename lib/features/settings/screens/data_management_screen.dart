import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../providers/data_provider.dart';
import '../../backups/providers/backup_provider.dart';
import '../widgets/data_action_widgets.dart';
import '../widgets/data_export_bottom_sheet.dart';
import '../widgets/data_import_bottom_sheet.dart';

String _getMockDataTitle(String lang) {
  switch (lang) {
    case 'hi': return 'प्रयोगात्मक डेटा उत्पन्न करें';
    case 'kn': return 'ಅಣಕು ಡೇಟಾವನ್ನು ರಚಿಸಿ';
    case 'mr': return 'प्रात्यक्षिक डेटा तयार करा';
    case 'pa': return 'ਨਕਲੀ ਡੇਟਾ ਤਿਆਰ ਕਰੋ';
    case 'bn': return 'মক ডেটা তৈরি করুন';
    case 'te': return 'మాక్ డేటాను సృష్టించండి';
    case 'ta': return 'போலி தரவை உருவாக்கவும்';
    case 'ml': return 'മോക്ക് ഡാറ്റ സൃഷ്ടിക്കുക';
    default: return 'Generate Mock Data';
  }
}

String _getMockDataDesc(String lang) {
  switch (lang) {
    case 'hi': return 'परीक्षण के लिए ऐप में वास्तविक दिखने वाले नमूना डेटा को भरें।';
    case 'kn': return 'ಪರೀಕ್ಷೆಗಾಗಿ ಆಪ್‌ನಲ್ಲಿ ನೈಜವಾಗಿ ಕಾಣುವ ಮಾದರಿ ಡೇಟಾವನ್ನು ಭರ್ತಿ ಮಾಡಿ.';
    case 'mr': return 'चाचणीसाठी अॅपमध्ये वास्तववादी नमुना डेटा भरा.';
    case 'pa': return 'ਟੈਸਟਿੰਗ ਲਈ ਐਪ ਵਿੱਚ ਅਸਲੀ ਵਰਗਾ ਨਮੂਨਾ ਡੇਟਾ ਭਰੋ।';
    case 'bn': return 'পরীক্ষার জন্য অ্যাপে বাস্তবসম্মত নমুনা ডেটা পূরণ করুন।';
    case 'te': return 'పరీక్ష కోసం యాప్‌లో వాస్తవిక నమూనా డేటాను పూరించండి.';
    case 'ta': return 'சோதனைக்காக செயலியில் யதார்த்தமான மாதிரி தரவை நிரப்பவும்.';
    case 'ml': return 'പരിശോധനയ്ക്കായി ആപ്പിൽ യഥാർത്ഥമെന്ന് തോന്നുന്ന മാതൃകാ ഡാറ്റ പൂരിപ്പിക്കുക.';
    default: return 'Populate the app with realistic sample data for testing.';
  }
}

String _getMockDataConfirmTitle(String lang) {
  switch (lang) {
    case 'hi': return 'प्रयोगात्मक डेटा उत्पन्न करें?';
    case 'kn': return 'ಅಣಕು ಡೇಟಾವನ್ನು ರಚಿಸಬೇಕೆ?';
    case 'mr': return 'प्रात्यक्षिक डेटा तयार करायचा?';
    case 'pa': return 'ਨਕਲੀ ਡੇਟਾ ਤਿਆਰ ਕਰਨਾ ਹੈ?';
    case 'bn': return 'মক ডেটা তৈরি করবেন?';
    case 'te': return 'మాక్ డేటాను సృష్టించాలా?';
    case 'ta': return 'போலி தரவை உருவாக்கவா?';
    case 'ml': return 'മോക്ക് ഡാറ്റ സൃഷ്ടിക്കണോ?';
    default: return 'Generate Mock Data?';
  }
}

String _getMockDataConfirmDesc(String lang) {
  switch (lang) {
    case 'hi': return 'सभी मौजूदा डेटा स्थायी रूप से हटा दिए जाएंगे और उनके स्थान पर नमूना डेटा डाल दिया जाएगा।';
    case 'kn': return 'ಅಸ್तिತ್ವದಲ್ಲಿರುವ ಎಲ್ಲಾ ಡೇಟಾವನ್ನು ಶಾಶ್ವತವಾಗಿ ಅಳಿಸಲಾಗುತ್ತದೆ ಮತ್ತು ಮಾದರಿ ಡೇಟಾದೊಂದಿಗೆ ಬದಲಾಯಿಸಲಾಗುತ್ತದೆ.';
    case 'mr': return 'सर्व विद्यमान डेटा कायमचा हटविला जाईल आणि नमुना डेटासह पुनर्स्थित केला जाईल.';
    case 'pa': return 'ਸਾਰਾ ਮੌਜੂਦਾ ਡੇਟਾ ਸਥਾਈ ਤੌਰ \'ਤੇ ਮਿਟਾ ਦਿੱਤਾ ਜਾਵੇਗਾ ਅਤੇ ਨਮੂਨੇ ਦੇ ਡੇਟਾ ਨਾਲ ਬਦਲ ਦਿੱਤਾ ਜਾਵੇਗਾ।';
    case 'bn': return 'বিদ্যমান সমস্ত ডেটা স্থায়ীভাবে মুছে ফেলা হবে এবং নমুনা ডেটা দিয়ে প্রতিস্থাপন করা হবে।';
    case 'te': return 'ఉన్న డేటా అంతా శాశ్వతంగా తొలగించబడుతుంది మరియు నమూనా డేటాతో భర్తీ చేయబడుతుంది.';
    case 'ta': return 'தற்போதுள்ள அனைத்து தரவும் நிரந்தரமாக நீக்கப்பட்டு, மாதிரி தரவுகளால் மாற்றப்படும்.';
    case 'ml': return 'നിലവിലുള്ള എല്ലാ ഡാറ്റയും ശാശ്വതമായി ഇല്ലാതാക്കപ്പെടുകയും മാതൃകാ ഡാറ്റ ഉപയോഗിച്ച് മാറ്റപ്പെടുകയും ചെയ്യും.';
    default: return 'All existing data will be permanently deleted and replaced with sample data.';
  }
}

String _getMockDataConfirmLabel(String lang) {
  switch (lang) {
    case 'hi': return 'उत्पन्न करें';
    case 'kn': return 'ರಚಿಸಿ';
    case 'mr': return 'तयार करा';
    case 'pa': return 'ਤਿਆਰ ਕਰੋ';
    case 'bn': return 'তৈরি করুন';
    case 'te': return 'సృష్టించు';
    case 'ta': return 'உருவாக்கு';
    case 'ml': return 'സൃഷ്ടിക്കുക';
    default: return 'Generate';
  }
}

String _getBackupFailedLabel(String lang) {
  switch (lang) {
    case 'hi': return 'पिछला बैकअप विफल रहा';
    case 'kn': return 'ಕೊನೆಯ ಬ್ಯಾಕಪ್ ವಿಫಲವಾಗಿದೆ';
    case 'mr': return 'शेवटचा बॅकअप अयशस्वी झाला';
    case 'pa': return 'ਆਖਰੀ ਬੈਕਅੱਪ ਅਸਫਲ ਰਿਹਾ';
    case 'bn': return 'শেষ ব্যাকআপ ব্যর্থ হয়েছে';
    case 'te': return 'చివరి బ్యాకప్ విఫలమైంది';
    case 'ta': return 'கடைசி காப்புப்பிரதி தோல்வியடைந்தது';
    case 'ml': return 'അവസാന ബാക്കപ്പ് പരാജയപ്പെട്ടു';
    default: return 'Last backup failed';
  }
}

String _getProcessingLabel(String lang) {
  switch (lang) {
    case 'hi': return 'प्रसंस्करण हो रहा है…';
    case 'kn': return 'ಪ್ರಕ್ರಿಯೆಗೊಳಿಸಲಾಗುತ್ತಿದೆ...';
    case 'mr': return 'प्रक्रिया सुरू आहे…';
    case 'pa': return 'ਕਾਰਵਾਈ ਚੱਲ ਰਹੀ ਹੈ…';
    case 'bn': return 'প্রক্রিয়াকরণ করা হচ্ছে…';
    case 'te': return 'ప్రక్రియ జరుగుతోంది…';
    case 'ta': return 'செயலாக்கப்படுகிறது…';
    case 'ml': return 'പ്രോസസ്സ് ചെയ്യുന്നു...';
    default: return 'Processing…';
  }
}

class DataManagementScreen extends ConsumerWidget {
  const DataManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final state = ref.watch(dataControllerProvider);
    final backupSettings = ref.watch(backupSettingsProvider).valueOrNull;
    final backupFailed = backupSettings?.status == BackupStatus.failed;
    final lang = AppLocale.current.languageCode;

    ref.listen(dataControllerProvider, (previous, next) {
      if (next.status == DataOpStatus.success && next.message != null) {
        showKuberSnackBar(context, next.message!);
        ref.read(dataControllerProvider.notifier).reset();
      } else if (next.status == DataOpStatus.error && next.message != null) {
        showKuberSnackBar(context, next.message!, isError: true);
        ref.read(dataControllerProvider.notifier).reset();
      }
    });

    return Scaffold(
      backgroundColor: cs.surface,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(
                child: KuberAppBar(showBack: true, showHome: true, title: ''),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.l10n.dataManagementTitle.replaceAll(' ', '\n'),
                        style: localeFont(
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          color: cs.onSurface,
                          height: 1.15,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        context.l10n.dataManagementDesc,
                        style: localeFont(
                          fontSize: 13,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverPadding(
                padding: const EdgeInsets.symmetric(
                  horizontal: KuberSpacing.lg,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    DataActionRow(
                      icon: Icons.upload_file_rounded,
                      title: context.l10n.exportData,
                      description: context.l10n.exportDataDesc,
                      onPressed: () => showDataExportBottomSheet(context),
                    ),
                    const SizedBox(height: KuberSpacing.md),
                    DataActionRow(
                      icon: Icons.download_rounded,
                      title: context.l10n.importData,
                      description: context.l10n.importDataDesc,
                      onPressed: () => showDataImportBottomSheet(context),
                    ),
                    const SizedBox(height: KuberSpacing.md),
                    DataActionRow(
                      icon: backupFailed
                          ? Icons.warning_amber_rounded
                          : Icons.backup_outlined,
                      title: context.l10n.backupTitle,
                      description: backupFailed
                          ? _getBackupFailedLabel(lang)
                          : context.l10n.backupDesc,
                      onPressed: () =>
                          context.push('/more/data/automatic-backups'),
                    ),
                    const SizedBox(height: KuberSpacing.md),
                    DataActionRow(
                      icon: Icons.science_outlined,
                      title: _getMockDataTitle(lang),
                      description: _getMockDataDesc(lang),
                      onPressed: () => _confirmMockData(context, ref),
                    ),
                    const SizedBox(height: KuberSpacing.md),
                    DataActionRow(
                      icon: Icons.delete_forever_rounded,
                      title: context.l10n.clearAllData,
                      description: context.l10n.clearAllDataDesc,
                      destructive: true,
                      onPressed: () => _confirmClearData(context, ref),
                    ),
                    const SizedBox(height: KuberSpacing.xxl),
                  ]),
                ),
              ),
            ],
          ),
          if (state.status == DataOpStatus.loading)
            DataLoadingOverlay(message: state.loadingMessage ?? _getProcessingLabel(lang)),
        ],
      ),
    );
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
        description: context.l10n.clearDataConfirmBody.replaceAll(' Type DELETE to confirm.', ''),
        confirmLabel: context.l10n.clearAllData,
        destructive: true,
        onConfirm: () =>
            ref.read(dataControllerProvider.notifier).clearAllData(),
      ),
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
        description: _getMockDataConfirmDesc(lang),
        confirmLabel: _getMockDataConfirmLabel(lang),
        warnDescription: true,
        onConfirm: () =>
            ref.read(dataControllerProvider.notifier).generateMockData(),
      ),
    );
  }
}