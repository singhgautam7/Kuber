import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/kuber_app_bar.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../providers/permission_provider.dart';
import '../../backups/providers/backup_provider.dart';

String _getNotificationsTitle(String lang) {
  switch (lang) {
    case 'hi':
      return 'सूचनाएं';
    case 'kn':
      return 'ಅಧಿಸೂಚನೆಗಳು';
    case 'mr':
      return 'अधिसूचना';
    case 'pa':
      return 'ਨੋਟੀਫਿਕੇਸ਼ਨ';
    case 'bn':
      return 'বিজ্ঞপ্তি';
    case 'te':
      return 'నోటిఫికేషన్లు';
    case 'ta':
      return 'அறிவிப்புகள்';
    case 'ml':
      return 'അറിയിപ്പുകൾ';
    default:
      return 'Notifications';
  }
}

String _getNotificationsDesc(String lang) {
  switch (lang) {
    case 'hi':
      return 'रिमाइंडर, आवर्ती लेनदेन और निर्यात पूरा होने के अपडेट के लिए उपयोग किया जाता है।';
    case 'kn':
      return 'ಜ್ಞಾಪನೆಗಳು, ಆವರ್ತಕ ವಹಿವಾಟುಗಳು ಮತ್ತು ರಫ್ತು ಪೂರ್ಣಗೊಂಡ ನವೀಕರಣಗಳಿಗಾಗಿ ಬಳಸಲಾಗುತ್ತದೆ.';
    case 'mr':
      return 'स्मरणपत्रे, आवर्ती व्यवहार आणि निर्यात पूर्ण झाल्याच्या अपडेट्ससाठी वापरले जाते.';
    case 'pa':
      return 'ਯਾਦ-ਦਹਾਨੀਆਂ, ਆਵਰਤੀ ਲੈਣ-ਦੇਣ ਅਤੇ ਨਿਰਯਾਤ ਪੂਰਾ ਹੋਣ ਦੇ ਅਪਡੇਟਾਂ ਲਈ ਵਰਤਿਆ ਜਾਂਦਾ ਹੈ।';
    case 'bn':
      return 'রিমাইন্ডার, পৌনঃপুনিক লেনদেন এবং এক্সপোর্ট সম্পন্ন হওয়ার আপডেটের জন্য ব্যবহৃত হয়।';
    case 'te':
      return 'రిమైండర్‌లు, ఆవర్తన లావాదేవీలు మరియు ఎగుమతి పూర్తయిన అప్‌డేట్‌ల కోసం ఉపయోగించబడుతుంది.';
    case 'ta':
      return 'நினைவூட்டல்கள், தொடர் பரிவர்த்தனைகள் மற்றும் ஏற்றுமதி நிறைவு அறிவிப்புகளுக்குப் பயன்படுத்தப்படுகிறது.';
    case 'ml':
      return 'ഓർമ്മപ്പെടുത്തലുകൾ, ആവർത്തിച്ചുള്ള ഇടപാടുകൾ, എക്‌സ്‌പോർട്ട് പൂർത്തിയാകൽ വിവരങ്ങൾ എന്നിവയ്ക്കായി ഉപയോഗിക്കുന്നു.';
    default:
      return 'Used for reminders, recurring transactions, and export completion updates.';
  }
}

String _getFilesTitle(String lang) {
  switch (lang) {
    case 'hi':
      return 'फ़ाइलें';
    case 'kn':
      return 'ಫೈಲ್‌ಗಳು';
    case 'mr':
      return 'फाइल्स';
    case 'pa':
      return 'ਫਾਈਲਾਂ';
    case 'bn':
      return 'ফাইলসমূহ';
    case 'te':
      return 'ఫైళ్ళు';
    case 'ta':
      return 'கோப்புகள்';
    case 'ml':
      return 'ഫയലുകൾ';
    default:
      return 'Files';
  }
}

String _getFilesDescNotSet(String lang) {
  switch (lang) {
    case 'hi':
      return 'केवल आपके द्वारा चुने गए बैकअप फ़ोल्डर के लिए उपयोग किया जाता है। फ़ोल्डर सेट होने तक स्वचालित बैकअप रुके रहते हैं।';
    case 'kn':
      return 'ನೀವು ಆಯ್ಕೆ ಮಾಡುವ ಬ್ಯಾಕಪ್ ಫೋಲ್ಡರ್‌ಗಾಗಿ ಮಾತ್ರ ಬಳಸಲಾಗುತ್ತದೆ. ಫೋಲ್ಡರ್ ಹೊಂದಿಸುವವರೆಗೆ ಸ್ವಯಂಚಾಲಿತ ಬ್ಯಾಕಪ್‌ಗಳನ್ನು ತാൽಕಾಲಿಕವಾಗಿ ನಿಲ್ಲಿಸಲಾಗುತ್ತದೆ.';
    case 'mr':
      return 'फक्त तुम्ही निवडलेल्या बॅकअप फोल्डरसाठी वापरले जाते. फोल्डर सेट करेपर्यंत स्वयंचलित बॅकअप तात्पुरते थांबवले जातात.';
    case 'pa':
      return 'ਸਿਰਫ਼ ਤੁਹਾਡੇ ਦੁਆਰਾ ਚੁਣੇ ਗਏ ਬੈਕਅੱਪ ਫੋਲਡਰ ਲਈ ਵਰਤਿਆ ਜਾਂਦਾ ਹੈ। ਫੋਲਡਰ ਸੈੱਟ ਹੋਣ ਤੱਕ ਆਟੋਮੈਟিক ਬੈਕਅੱਪ ਰੁਕੇ ਰਹਿੰਦੇ ਹਨ।';
    case 'bn':
      return 'শুধুমাত্র আপনার নির্বাচিত ব্যাকআপ ফোল্ডারের জন্য ব্যবহৃত হয়। ফোল্ডার সেট না করা পর্যন্ত স্বয়ংক্রিয় ব্যাকআপ স্থগিত থাকবে।';
    case 'te':
      return 'మీరు ఎంచుకున్న బ్యాకప్ ఫోల్డర్ కోసం మాత్రమే ఉపయోగించబడుతుంది. ఫోల్డర్ సెట్ చేసే వరకు ఆటోమేటిక్ బ్యాకప్‌లు పాజ్ చేయబడతాయి.';
    case 'ta':
      return 'நீங்கள் தேர்ந்தெடுக்கும் காப்புப்பிரதி கோப்புறைக்கு மட்டுமே பயன்படுத்தப்படுகிறது. கோப்புறை அமைக்கப்படும் வரை தானியங்கி காப்புப்பிரதி இடைநிறுத்தப்படும்.';
    case 'ml':
      return 'നിങ്ങൾ തിരഞ്ഞെടുക്കുന്ന ബാക്കപ്പ് ഫോൾഡറിനായി മാത്രം ഉപയോഗിക്കുന്നു. ഫോൾഡർ സജ്ജീകരിക്കുന്നത് വരെ സ്വയമേവയുള്ള ബാക്കപ്പ് നിർത്തിവെയ്ക്കും.';
    default:
      return 'Used only for the backup folder you choose. Automatic backups stay paused until a folder is set.';
  }
}

String _getFilesDescGranted(String lang) {
  switch (lang) {
    case 'hi':
      return 'कुबेर को केवल आपके द्वारा चुने गए एक फ़ोल्डर में बैकअप प्रतियां लिखने की अनुमति देता है, और आपके डिवाइस पर कुछ भी नहीं।';
    case 'kn':
      return 'ಕುಬೇರನಿಗೆ ನೀವು ಆರಿಸಿದ ಒಂದು ಫೋಲ್ಡರ್‌ಗೆ ಮಾತ್ರ ಬ್ಯಾಕಪ್ ನಕಲುಗಳನ್ನು ಬರೆಯಲು ಅನುಮತಿಸುತ್ತದೆ, ಸಾಧನದಲ್ಲಿ ಬೇರೇನನ್ನೂ ಬದಲಾಯಿಸುವುದಿಲ್ಲ.';
    case 'mr':
      return 'कुबेरला फक्त तुम्ही निवडलेल्या एका फोल्डरमध्ये बॅकअप प्रती लिहिण्याची परवानगी देते, तुमच्या डिव्हाइसवरील इतर कशातही नाही.';
    case 'pa':
      return 'ਕੁਬੇਰ ਨੂੰ ਸਿਰਫ਼ ਤੁਹਾਡੇ ਦੁਆਰਾ ਚੁਣੇ ਗਏ ਇੱਕ ਫੋਲਡਰ ਵਿੱਚ ਬੈਕਅੱਪ ਕਾਪੀਆਂ ਲਿਖਣ ਦੀ ਇਜਾਜ਼ਤ ਦਿੰਦਾ ਹੈ, ਡਿਵਾਈਸ \'ਤੇ ਹੋਰ ਕੁਝ ਨਹੀਂ।';
    case 'bn':
      return 'কুবেরকে শুধুমাত্র আপনার বেছে নেওয়া ফোল্ডারে ব্যাকআপ কপি লিখতে দেয়, আপনার ডিভাইসের অন্য কিছু অ্যাক্সেস করে না।';
    case 'te':
      return 'కుబేర్ మీరు ఎంచుకున్న ఒక ఫోల్డర్‌కు మాత్రమే బ్యాకప్ కాపీలను రాయడానికి అనుమతిస్తుంది, మీ పరికరంలో మరేదీ యాక్సెస్ చేయదు.';
    case 'ta':
      return 'நீங்கள் தேர்ந்தெடுத்த ஒரு கோப்புறைக்கு மட்டுமே காப்புப்பிரதி நகல்களை எழுத குபேரை அனுமதிக்கிறது, சாதனத்தில் வேறு எதையும் அணுகாது.';
    case 'ml':
      return 'നിങ്ങൾ തിരഞ്ഞെടുത്ത ഒരു ഫോൾഡറിലേക്ക് മാത്രം ബാക്കപ്പ് പകർപ്പുകൾ എഴുതാൻ കുബേറിനെ അനുവദിക്കുന്നു, ഉപകരണത്തിൽ മറ്റൊന്നും ആക്‌സസ് ചെയ്യില്ല.';
    default:
      return 'Lets Kuber write backup copies to the one folder you picked, and nothing else on your device.';
  }
}

String _getOpenSettingsLabel(String lang) {
  switch (lang) {
    case 'hi':
      return 'सिस्टम सेटिंग्स खोलें';
    case 'kn':
      return 'ಸಿಸ್ಟಮ್ ಸೆಟ್ಟಿಂಗ್‌ಗಳನ್ನು ತೆರೆಯಿರಿ';
    case 'mr':
      return 'सिस्टम सेटिंग्ज उघडा';
    case 'pa':
      return 'ਸਿਸਟਮ ਸੈਟਿੰਗਾਂ ਖੋਲ੍ਹੋ';
    case 'bn':
      return 'সিস্টেম সেটিংস খুলুন';
    case 'te':
      return 'సిస్టమ్ సెట్టింగ్‌లను తెరవండి';
    case 'ta':
      return 'கணினி அமைப்புகளைத் திறக்கவும்';
    case 'ml':
      return 'സിസ്റ്റം ക്രമീകരണങ്ങൾ തുറക്കുക';
    default:
      return 'Open System Settings';
  }
}

String _getBadgeText(
  AppPermissionStatus status,
  String? override,
  String lang,
) {
  if (override != null) {
    if (override == 'NOT SET') {
      switch (lang) {
        case 'hi':
          return 'सेट नहीं है';
        case 'kn':
          return 'ಹೊಂದಿಸಿಲ್ಲ';
        case 'mr':
          return 'सेट नाही';
        case 'pa':
          return 'ਸੈੱਟ ਨਹੀਂ';
        case 'bn':
          return 'সেট করা নেই';
        case 'te':
          return 'సెట్ చేయలేదు';
        case 'ta':
          return 'அமைக்கப்படவில்லை';
        case 'ml':
          return 'സജ്ജീകരിച്ചിട്ടില്ല';
        default:
          return 'NOT SET';
      }
    }
    if (override == 'GRANTED') {
      switch (lang) {
        case 'hi':
          return 'स्वीकृत';
        case 'kn':
          return 'ಅನುಮತಿಸಲಾಗಿದೆ';
        case 'mr':
          return 'मंजूर';
        case 'pa':
          return 'ਮਨਜ਼ੂਰ';
        case 'bn':
          return 'অনুমোদিত';
        case 'te':
          return 'అనుమతించబడింది';
        case 'ta':
          return 'அனுமதிக்கப்பட்டது';
        case 'ml':
          return 'അനുവദിച്ചു';
        default:
          return 'GRANTED';
      }
    }
    if (override == 'ALWAYS GRANTED') {
      switch (lang) {
        case 'hi':
          return 'हमेशा स्वीकृत';
        case 'kn':
          return 'ಯಾವಾಗಲೂ ಅನುಮತಿಸಲಾಗಿದೆ';
        case 'mr':
          return 'नेहमी मंजूर';
        case 'pa':
          return 'ਹਮੇਸ਼ਾ ਮਨਜ਼ੂਰ';
        case 'bn':
          return 'সর্বদা অনুমোদিত';
        case 'te':
          return 'ఎల్లప్పుడూ అనుమతించబడింది';
        case 'ta':
          return 'எப்போதும் அனுமதிக்கப்பட்டது';
        case 'ml':
          return 'എപ്പോഴും അനുവദിച്ചു';
        default:
          return 'ALWAYS GRANTED';
      }
    }
    if (override == 'NOT AVAILABLE') {
      switch (lang) {
        case 'hi':
          return 'अनुपलब्ध';
        case 'kn':
          return 'ಲಭ್ಯವಿಲ್ಲ';
        case 'mr':
          return 'उपलब्ध नाही';
        case 'pa':
          return 'ਉਪਲਬਧ ਨਹੀਂ';
        case 'bn':
          return 'অনুপলব্ধ';
        case 'te':
          return 'అందుబాటులో లేదు';
        case 'ta':
          return 'கிடைக்கவில்லை';
        case 'ml':
          return 'ലഭ്യമല്ല';
        default:
          return 'NOT AVAILABLE';
      }
    }
  }

  switch (status) {
    case AppPermissionStatus.granted:
      switch (lang) {
        case 'hi':
          return 'स्वीकृत';
        case 'kn':
          return 'ಅನುಮತಿಸಲಾಗಿದೆ';
        case 'mr':
          return 'मंजूर';
        case 'pa':
          return 'ਮਨਜ਼ੂਰ';
        case 'bn':
          return 'অনুমোদিত';
        case 'te':
          return 'అనుమతించబడింది';
        case 'ta':
          return 'அனுமதிக்கப்பட்டது';
        case 'ml':
          return 'അനുവദിച്ചു';
        default:
          return 'GRANTED';
      }
    case AppPermissionStatus.denied:
      switch (lang) {
        case 'hi':
          return 'अस्वीकृत';
        case 'kn':
          return 'ಅನುಮತಿಸಿಲ್ಲ';
        case 'mr':
          return 'मंजूर नाही';
        case 'pa':
          return 'ਨਾ-ਮਨਜ਼ੂਰ';
        case 'bn':
          return 'অনুমতিহীন';
        case 'te':
          return 'అనుమతించబడలేదు';
        case 'ta':
          return 'அனுமதிக்கப்படவில்லை';
        case 'ml':
          return 'അനുവദിച്ചിട്ടില്ല';
        default:
          return 'NOT GRANTED';
      }
    case AppPermissionStatus.notRequired:
      switch (lang) {
        case 'hi':
          return 'आवश्यक नहीं है';
        case 'kn':
          return 'ಅಗತ್ಯವಿಲ್ಲ';
        case 'mr':
          return 'आवश्यक नाही';
        case 'pa':
          return 'ਲੋੜ ਨਹੀਂ';
        case 'bn':
          return 'প্রয়োজন নেই';
        case 'te':
          return 'అవసరం లేదు';
        case 'ta':
          return 'தேவையில்லை';
        case 'ml':
          return 'ആവശ്യമില്ല';
        default:
          return 'NOT REQUIRED';
      }
  }
}

class PermissionsScreen extends ConsumerWidget {
  const PermissionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final permissionState = ref.watch(permissionProvider);
    final backupSettings = ref.watch(backupSettingsProvider).valueOrNull;
    final lang = AppLocale.current.languageCode;

    return Scaffold(
      backgroundColor: cs.surface,
      body: KuberScrollAwayHeader(
        header: KuberAppBar(
          showBack: true,
          title: context.l10n.permissionsTitle,
        ),
        body: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.symmetric(
                horizontal: KuberSpace.screenMargin,
              ),
              sliver: permissionState.when(
                data: (state) => SliverList(
                  delegate: SliverChildListDelegate([
                    KuberGroup(
                      children: [
                        _PermissionCard(
                          icon: Icons.notifications_none_rounded,
                          title: _getNotificationsTitle(lang),
                          description: _getNotificationsDesc(lang),
                          status: state.notifications,
                          lang: lang,
                          onTap: () => ref
                              .read(permissionProvider.notifier)
                              .requestNotification(),
                        ),
                        _PermissionCard(
                          icon: Icons.sms_outlined,
                          title: 'SMS',
                          description:
                              'Used to detect your bank\'s transaction messages and '
                              'suggest them for import. Read-only. Nothing is stored '
                              'or transmitted without your approval.',
                          status: state.sms,
                          lang: lang,
                          onTap: () => ref
                              .read(permissionProvider.notifier)
                              .requestSms(),
                        ),
                        _PermissionCard(
                          icon: Icons.mic_none_rounded,
                          title: 'Microphone',
                          description:
                              'Used only for Quick Add voice input. Speech is '
                              'recognized on your device. Nothing is recorded or '
                              'transmitted.',
                          status: state.microphone,
                          lang: lang,
                          onTap: () => ref
                              .read(permissionProvider.notifier)
                              .requestMicrophone(),
                        ),
                        _PermissionCard(
                          icon: Icons.folder_special_outlined,
                          title: _getFilesTitle(lang),
                          description: backupSettings?.folderPath == null
                              ? _getFilesDescNotSet(lang)
                              : _getFilesDescGranted(lang),
                          status: backupSettings?.folderPath == null
                              ? AppPermissionStatus.denied
                              : AppPermissionStatus.granted,
                          statusTextOverride: backupSettings?.folderPath == null
                              ? 'NOT SET'
                              : 'GRANTED',
                          lang: lang,
                          onTap: () => ref
                              .read(backupSettingsProvider.notifier)
                              .pickFolder(),
                        ),
                        _PermissionCard(
                          icon: Icons.fingerprint_rounded,
                          title: context.l10n.biometricPermission,
                          description: context.l10n.biometricPermissionDesc,
                          status: state.isBiometricAvailable
                              ? (state.isBiometricEnabled
                                    ? AppPermissionStatus.granted
                                    : AppPermissionStatus.denied)
                              : AppPermissionStatus.notRequired,
                          statusTextOverride: !state.isBiometricAvailable
                              ? 'NOT AVAILABLE'
                              : null,
                          lang: lang,
                        ),
                        _PermissionCard(
                          icon: Icons.wifi_rounded,
                          title: context.l10n.networkPermission,
                          description: context.l10n.networkPermissionDesc,
                          status: AppPermissionStatus.granted,
                          statusTextOverride: 'ALWAYS GRANTED',
                          lang: lang,
                        ),
                      ],
                    ),
                    const SizedBox(height: KuberSpace.xl),
                    AppButton(
                      label: _getOpenSettingsLabel(lang),
                      icon: Icons.settings_outlined,
                      type: AppButtonType.outline,
                      fullWidth: true,
                      onPressed: () => openAppSettings(),
                    ),
                    SizedBox(
                      height: KuberSpace.xxl + systemNavBarInset(context),
                    ),
                  ]),
                ),
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (err, stack) => SliverFillRemaining(
                  child: Center(child: Text('Error: $err')),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PermissionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final AppPermissionStatus status;
  final String? statusTextOverride;
  final String lang;
  final VoidCallback? onTap;

  const _PermissionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.status,
    required this.lang,
    this.statusTextOverride,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final badgeText = _getBadgeText(status, statusTextOverride, lang);
    // Pills: income container for granted, warning for not set, neutral for
    // not granted / not available (board 3.28).
    final tone = switch (status) {
      AppPermissionStatus.granted => KuberTone.income,
      _ when statusTextOverride == 'NOT SET' => KuberTone.warning,
      _ => KuberTone.neutral,
    };

    return KuberListRow(
      leading: KuberIconTile(icon: icon),
      title: title,
      titleTrailing: KuberPill(label: badgeText, tone: tone),
      subtitle: description,
      subtitleLines: 6,
      onTap: status == AppPermissionStatus.denied ? onTap : null,
    );
  }
}
