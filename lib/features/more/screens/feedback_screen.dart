import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_chips.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../settings/providers/settings_provider.dart';

const _feedbackTypes = ['Bug', 'New Feature Request', 'General Feedback'];

String _getDeviceDetailsNote(String lang) {
  switch (lang) {
    case 'hi':
      return 'जब आप सबमिट करेंगे, तो आपके फीडबैक को बेहतर ढंग से समझने और हल करने में हमारी मदद के लिए कुछ बुनियादी डिवाइस विवरण (जैसे मॉडल, ओएस संस्करण, ऐप संस्करण और आपका इन-ऐप नाम) शामिल किए जाएंगे।';
    case 'kn':
      return 'ನೀವು ಸಲ್ಲಿಸಿದಾಗ, ನಿಮ್ಮ ಪ್ರತಿಕ್ರಿಯೆಯನ್ನು ಉತ್ತಮವಾಗಿ ಅರ್ಥಮಾಡಿಕೊಳ್ಳಲು ಮತ್ತು ಪರಿಹರಿಸಲು ನಮಗೆ ಸಹಾಯ ಮಾಡಲು ಕೆಲವು ಮೂಲಭೂത ಸಾಧನದ ವಿವರಗಳನ್ನು (ಮಾದರಿ, ಓಎಸ್ ಆವೃತ್ತಿ, ಆಪ್ ಆವೃತ್ತಿ ಮತ್ತು ನಿಮ್ಮ ಇನ್-ಆಪ್ ಹೆಸರು) ಸೇರಿಸಲಾಗುತ್ತದೆ.';
    case 'mr':
      return 'तुम्ही सबमिट करता तेव्हा, तुमच्या अभिप्रायाचे चांगल्या प्रकारे आकलन आणि निराकरण करण्यात आम्हाला मदत करण्यासाठी काही मूलभूत डिव्हाइस तपशील (जसे की मॉडेल, ओएस व्हर्जन, अॅप व्हर्जन आणि तुमचे इन-अॅप नाव) समाविष्ट केले जातील.';
    case 'pa':
      return 'ਜਦੋਂ ਤੁਸੀਂ ਸਬਮਿਟ ਕਰਦੇ ਹੋ, ਤਾਂ ਤੁਹਾਡੀ ਫੀਡਬੈਕ ਨੂੰ ਬਹੀਤਰ ਢੰਗ ਨਾਲ ਸਮਝਣ ਅਤੇ ਹੱਲ ਕਰਨ ਵਿੱਚ ਸਾਡੀ ਮਦਦ ਲਈ ਕੁਝ ਬੁਨਿਆਦੀ ਡਿਵਾਈਸ ਵੇਰਵੇ (ਜਿਵੇਂ ਕਿ ਮਾਡਲ, OS ਵਰਜ਼ਨ, ਐਪ ਵਰਜ਼ਨ, ਅਤੇ ਤੁਹਾਡਾ ਇਨ-ਐਪ ਨਾਮ) ਸ਼ਾਮਲ ਕੀਤੇ ਜਾਣਗੇ।';
    case 'bn':
      return 'আপনি যখন জমা দেবেন, তখন আপনার প্রতিক্রিয়া আরও ভালভাবে বুঝতে এবং সমাধান করতে আমাদের সহায়তা করার জন্য কিছু মৌলিক ডিভাইসের বিবরণ (যেমন মডেল, ওএস সংস্করণ, অ্যাপ সংস্করণ এবং আপনার ইন-অ্যাপ নাম) অন্তর্ভুক্ত করা হবে।';
    case 'te':
      return 'మీరు సబ్మిట్ చేసినప్పుడు, మీ అభిప్రాయాన్ని మరింత మెరుగ్గా అర్థం చేసుకోవడానికి మరియు పరిష్కరించడానికి మాకు సహాయపడటానికి కొన్ని ప్రాథమిక పరికర వివరాలు (మోడల్, OS వెర్షన్, యాప్ వెర్షన్ మరియు మీ ఇన్-యాప్ పేరు వంటివి) చేర్చబడతాయి।';
    case 'ta':
      return 'நீங்கள் சமர்ப்பிக்கும் போது, உங்கள் கருத்தை சிறப்பாகப் புரிந்து கொண்டு தீர்க்க எங்களுக்கு உதவ, சில அடிப்படை சாதன விவரங்கள் (மாடல், ஓஎஸ் பதிப்பு, ஆப் பதிப்பு மற்றும் உங்கள் இன்-ஆப் பெயர் போன்றவை) சேர்க்கப்படும்.';
    case 'ml':
      return 'നിങ്ങൾ സമർപ്പിക്കുമ്പോൾ, നിങ്ങളുടെ ഫീഡ്‌ബാക്ക് നന്നായി മനസിലാക്കാനും പരിഹരിക്കാനും ഞങ്ങളെ സഹായിക്കുന്നതിന് ചില അടിസ്ഥാന ഉപകരണ വിശദാംശങ്ങൾ (മോഡൽ, ഒഎസ് പതിപ്പ്, ആപ്പ് പതിപ്പ്, നിങ്ങളുടെ ഇൻ-ആപ്പ് പേര് എന്നിവ പോലെ) ഉൾപ്പെടുത്തും.';
    default:
      return 'When you submit, a few basic device details (like model, OS version, app version, and your in-app name) will be included to help us better understand and resolve your feedback.';
  }
}

String _getMailErrorMsg(String lang) {
  switch (lang) {
    case 'hi':
      return 'मेल ऐप नहीं खोला जा सका। कृपया पुनः प्रयास करें।';
    case 'kn':
      return 'ಮೇಲ್ ಆಪ್ ತೆರೆಯಲು ಸಾಧ್ಯವಾಗಲಿಲ್ಲ. ദയവിಟ್ಟು ಮತ್ತൊಮ್ಮೆ ಪ್ರಯತ್ನಿಸಿ.';
    case 'mr':
      return 'मेल अॅप उघडता आले नाही. कृपया पुन्हा प्रयत्न करा.';
    case 'pa':
      return 'ਮੇਲ ਐਪ ਨਹੀਂ ਖੋਲ੍ਹਿਆ ਜਾ ਸਕਿਆ। ਕਿਰਪਾ ਕਰਕੇ ਦੁਬਾਰਾ ਕੋਸ਼ਿਸ਼ ਕਰੋ।';
    case 'bn':
      return 'মেল অ্যাপ খোলা যায়নি। দয়া করে আবার চেষ্টা করুন।';
    case 'te':
      return 'మెయిల్ యాప్‌ను తెరవలేకపోయాము. దయచేసి మళ్లీ ప్రయత్నించండి.';
    case 'ta':
      return 'மின்னஞ்சல் செயலியைத் திறக்க முடியவில்லை. தயவுசெய்து மீண்டும் முயற்சிக்கவும்.';
    case 'ml':
      return 'മെയിൽ ആപ്പ് തുറക്കാൻ കഴിഞ്ഞില്ല. ദയവായി വീണ്ടും ശ്രമിക്കുക.';
    default:
      return 'Could not open mail app. Please try again.';
  }
}

class FeedbackScreen extends ConsumerStatefulWidget {
  /// Optional text to pre-fill the message field with (e.g. an unanswered Ask
  /// Kuber query routed here via a "Share your feedback" chip).
  final String? prefill;

  const FeedbackScreen({super.key, this.prefill});

  @override
  ConsumerState<FeedbackScreen> createState() => _FeedbackScreenState();
}

class _FeedbackScreenState extends ConsumerState<FeedbackScreen> {
  String _selectedType = _feedbackTypes.first;
  final _feedbackCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final prefill = widget.prefill;
    if (prefill != null && prefill.isNotEmpty) {
      _feedbackCtrl.text = prefill;
      _feedbackCtrl.selection = TextSelection.collapsed(offset: prefill.length);
    }
  }

  @override
  void dispose() {
    _feedbackCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final feedbackText = _feedbackCtrl.text.trim();
    if (feedbackText.isEmpty) {
      showKuberSnackBar(
        context,
        context.l10n.feedbackMessageRequired,
        isError: true,
      );
      return;
    }

    // Capture context-dependent values before async gaps
    final size = MediaQuery.of(context).size;
    final screenSize = '${size.width.toInt()} x ${size.height.toInt()}';
    final settings = ref.read(settingsProvider).valueOrNull;
    final currency = ref.read(currencyProvider);

    setState(() => _isSubmitting = true);

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final deviceInfo = DeviceInfoPlugin();

      String deviceModel = 'Unknown';
      String osVersion = 'Unknown';

      if (Platform.isAndroid) {
        final android = await deviceInfo.androidInfo;
        deviceModel = '${android.manufacturer} ${android.model}';
        osVersion =
            'Android ${android.version.release} (SDK ${android.version.sdkInt})';
      } else if (Platform.isIOS) {
        final ios = await deviceInfo.iosInfo;
        deviceModel = ios.model;
        osVersion = 'iOS ${ios.systemVersion}';
      }

      final subject = '[Kuber Feedback] $_selectedType';
      final body =
          '''
Type: $_selectedType

Feedback:
$feedbackText

---
Device Info
-----------
App Version : ${packageInfo.version} (${packageInfo.buildNumber})
Device      : $deviceModel
OS          : $osVersion
Screen Size : $screenSize
User Name   : ${settings?.userName.isNotEmpty == true ? settings!.userName : 'Not set'}
Currency    : ${currency.name} (${currency.code})
''';

      // Build mailto URI manually — Uri(queryParameters:) encodes spaces as +
      // which mail clients render literally. Uri.encodeComponent uses %20 instead.
      final uri = Uri.parse(
        'mailto:singhgautam.dev@gmail.com'
        '?subject=${Uri.encodeComponent(subject)}'
        '&body=${Uri.encodeComponent(body)}',
      );

      if (!await launchUrl(uri)) {
        if (mounted) {
          final lang = AppLocale.current.languageCode;
          showKuberSnackBar(context, _getMailErrorMsg(lang), isError: true);
        }
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final tt = theme.textTheme;
    final lang = AppLocale.current.languageCode;

    String typeLabel(String t) => switch (t) {
      'Bug' => context.l10n.feedbackTypeBug,
      'New Feature Request' => context.l10n.feedbackTypeFeature,
      'General Feedback' => context.l10n.feedbackTypeOther,
      _ => t,
    };

    return Scaffold(
      backgroundColor: cs.surface,
      body: KuberScrollAwayHeader(
        header: KuberAppBar(showBack: true, title: context.l10n.feedbackTitle),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  KuberSpace.screenMargin,
                  0,
                  KuberSpace.screenMargin,
                  KuberSpace.xl,
                ),
                children: [
                  KuberSectionHeader(title: context.l10n.feedbackType),
                  Wrap(
                    spacing: KuberSpace.sm,
                    runSpacing: KuberSpace.sm,
                    children: [
                      for (final t in _feedbackTypes)
                        KuberChip(
                          label: typeLabel(t),
                          selected: _selectedType == t,
                          onTap: () => setState(() => _selectedType = t),
                        ),
                    ],
                  ),
                  const SizedBox(height: KuberSpace.sectionGap - 4),
                  KuberSectionHeader(title: context.l10n.feedbackMessage),
                  TextField(
                    controller: _feedbackCtrl,
                    minLines: 5,
                    maxLines: 8,
                    style: tt.bodyLarge?.copyWith(color: cs.onSurface),
                    decoration: InputDecoration(
                      hintText: context.l10n.feedbackMessageHint,
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: KuberSpace.lg),
                  Container(
                    padding: const EdgeInsets.all(KuberSpace.md),
                    decoration: BoxDecoration(
                      color: cs.surfaceContainer,
                      borderRadius: KuberShape.cardR,
                      border: Border.all(color: cs.outlineVariant),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: KuberSpace.sm),
                        Expanded(
                          child: Text(
                            _getDeviceDetailsNote(lang),
                            style: tt.bodySmall!.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Pinned submit, sentence case (board 3.31).
            Divider(height: 1, thickness: 1, color: cs.outlineVariant),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  KuberSpace.screenMargin,
                  KuberSpace.md,
                  KuberSpace.screenMargin,
                  KuberSpace.lg,
                ),
                child: AppButton(
                  label: context.l10n.submitFeedback,
                  icon: Icons.send_outlined,
                  type: AppButtonType.primary,
                  fullWidth: true,
                  isLoading: _isSubmitting,
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
