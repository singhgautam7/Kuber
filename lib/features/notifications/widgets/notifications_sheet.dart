import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:kuber/core/utils/date_formatter.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/kuber_empty_state.dart';
import '../data/app_notification.dart';

String _getGroupTitle(NotificationType type, String lang) {
  switch (type) {
    case NotificationType.general:
      switch (lang) {
        case 'hi':
          return 'सामान्य';
        case 'kn':
          return 'ಸಾಮಾನ್ಯ';
        case 'mr':
          return 'सामान्य';
        case 'pa':
          return 'ਸਧਾਰਨ';
        case 'bn':
          return 'সাধারণ';
        case 'te':
          return 'సాధారణ';
        case 'ta':
          return 'பொதுவானவை';
        case 'ml':
          return 'പൊതുവായത്';
        default:
          return 'General';
      }
    case NotificationType.budgetAlert:
      switch (lang) {
        case 'hi':
          return 'बजट अलर्ट';
        case 'kn':
          return 'ಬಜೆಟ್ ಎಚ್ಚರಿಕೆಗಳು';
        case 'mr':
          return 'बजेट अलर्ट';
        case 'pa':
          return 'ਬਜਟ ਅਲਰਟ';
        case 'bn':
          return 'বাজেট সতর্কতা';
        case 'te':
          return 'బడ్జెట్ అలర్ట్‌లు';
        case 'ta':
          return 'பட்ஜெட் எச்சரிக்கைகள்';
        case 'ml':
          return 'ബജറ്റ് അലേർട്ടുകൾ';
        default:
          return 'Budget Alerts';
      }
    case NotificationType.recurringTransaction:
      switch (lang) {
        case 'hi':
          return 'आवर्ती लेनदेन';
        case 'kn':
          return 'ಆವರ್ತಕ ವಹಿವಾಟುಗಳು';
        case 'mr':
          return 'आवर्ती व्यवहार';
        case 'pa':
          return 'ਆਵਰਤੀ ਲੈਣ-ਦੇਣ';
        case 'bn':
          return 'পৌনঃপুনিক লেনদেন';
        case 'te':
          return 'ఆవర్తన లావాదేవీలు';
        case 'ta':
          return 'தொடர் பரிவர்த்தனைகள்';
        case 'ml':
          return 'ആവർത്തിച്ചുള്ള ഇടപാടുകൾ';
        default:
          return 'Recurring Transactions';
      }
    case NotificationType.loanEmi:
      switch (lang) {
        case 'hi':
          return 'ऋण ईएमआई';
        case 'kn':
          return 'ಸಾಲದ ಇಎಂಐ';
        case 'mr':
          return 'कर्ज ईएमआय';
        case 'pa':
          return 'ਕਰਜ਼ਾ ਈਐਮਆਈ';
        case 'bn':
          return 'ঋণ ইএমআই';
        case 'te':
          return 'రుణ EMI';
        case 'ta':
          return 'கடன் இஎம்ஐ';
        case 'ml':
          return 'ലോൺ ഇഎംഐ';
        default:
          return 'Loan EMI';
      }
    case NotificationType.ledgerReminder:
      switch (lang) {
        case 'hi':
          return 'लेजर अनुस्मारक';
        case 'kn':
          return 'ಲೆಡ್ಜರ್ ಜ್ಞಾಪನೆಗಳು';
        case 'mr':
          return 'लेजर स्मरणपत्रे';
        case 'pa':
          return 'ਲੈਜਰ ਯਾਦ-ਦਹਾਨੀਆਂ';
        case 'bn':
          return 'লেজার রিমাইন্ডার';
        case 'te':
          return 'లెడ్జర్ రిమైండర్‌లు';
        case 'ta':
          return 'பேரேடு நினைவூட்டல்கள்';
        case 'ml':
          return 'ലെഡ്ജർ ഓർമ്മപ്പെടുത്തലുകൾ';
        default:
          return 'Ledger Reminders';
      }
    case NotificationType.backup:
      switch (lang) {
        case 'hi':
          return 'बैकअप';
        case 'kn':
          return 'ಬ್ಯಾಕಪ್';
        case 'mr':
          return 'बॅकअप';
        case 'pa':
          return 'ਬੈਕਅੱਪ';
        case 'bn':
          return 'ব্যাকআপ';
        case 'te':
          return 'బ్యాకప్';
        case 'ta':
          return 'காப்புப்பிரதி';
        case 'ml':
          return 'ബാക്കപ്പ്';
        default:
          return 'Backup';
      }
    case NotificationType.reminderTrigger:
      // Reminders are an English-only feature (SMS import precedent).
      return 'Reminders';
  }
}

String _getConfirmClearTitle(String lang) {
  switch (lang) {
    case 'hi':
      return 'सभी सूचनाएं हटाना चाहते हैं?';
    case 'kn':
      return 'ಎಲ್ಲಾ ಅಧಿಸೂಚನೆಗಳನ್ನು ತೆರವುಗೊಳಿಸಬೇಕೆ?';
    case 'mr':
      return 'सर्व अधिसूचना साफ करायच्या?';
    case 'pa':
      return 'ਸਾਰੀਆਂ ਨੋਟੀਫਿਕੇਸ਼ਨਾਂ ਨੂੰ ਸਾਫ਼ ਕਰਨਾ ਹੈ?';
    case 'bn':
      return 'সমস্ত বিজ্ঞপ্তি মুছে ফেলতে চান?';
    case 'te':
      return 'అన్ని నోటిఫికేషన్‌లను తొలగించాలా?';
    case 'ta':
      return 'அனைத்து அறிவிப்புகளையும் அழிக்கவா?';
    case 'ml':
      return 'എല്ലാ അറിയിപ്പുകളും ഒഴിവാക്കണോ?';
    default:
      return 'Clear all notifications?';
  }
}

String _getConfirmClearBody(String lang) {
  switch (lang) {
    case 'hi':
      return 'यह सभी सूचनाओं को स्थायी रूप से हटा देगा। इसे पूर्ववत नहीं किया जा सकता।';
    case 'kn':
      return 'ಇದು ಎಲ್ಲಾ ಅಧಿಸೂಚನೆಗಳನ್ನು ಶಾಶ್ವതವಾಗಿ ತೆಗೆದುಹಾകುತ್ತದೆ. ಇದನ್ನು ಹಿಂಪಡೆಯಲು ಸಾಧ್ಯವಿಲ್ಲ.';
    case 'mr':
      return 'हे कायमचे सर्व अधिसूचना काढून टाकेल. हे पूर्ववत केले जाऊ शकत नाही.';
    case 'pa':
      return 'ਇਹ ਸਾਰੀਆਂ ਨੋਟੀਫਿਕੇਸ਼ਨਾਂ ਨੂੰ ਪੱਕੇ ਤੌਰ \'ਤੇ ਹਟਾ ਦੇਵੇਗਾ। ਇਸਨੂੰ ਵਾਪਸ ਨਹੀਂ ਲਿਆਂਦਾ ਜਾ ਸਕਦਾ।';
    case 'bn':
      return 'এটি স্থায়ীভাবে সমস্ত বিজ্ঞপ্তি সরিয়ে দেবে। এটি আর ফিরিয়ে আনা যাবে না।';
    case 'te':
      return 'ఇది అన్ని నోటిఫికేషన్‌లను శాశ్వతంగా తొలగిస్తుంది. ఈ చర్యను తిరిగి మార్చలేము.';
    case 'ta':
      return 'இது அனைத்து அறிவிப்புகளையும் நிரந்தரமாக அகற்றும். இதை மாற்ற முடியாது.';
    case 'ml':
      return 'ഇത് എല്ലാ അറിയിപ്പുകളും ശാശ്വതമായി ഇല്ലാതാക്കും. ഇത് പഴയപടിയാക്കാൻ കഴിയില്ല.';
    default:
      return 'This will permanently remove all notifications. This cannot be undone.';
  }
}

String _getClearAllLabel(String lang) {
  switch (lang) {
    case 'hi':
      return 'सभी हटाएं';
    case 'kn':
      return 'ಎಲ್ಲವನ್ನೂ ತೆರವುಗೊಳಿಸಿ';
    case 'mr':
      return 'सर्व साफ करा';
    case 'pa':
      return 'ਸਭ ਸਾਫ਼ ਕਰੋ';
    case 'bn':
      return 'সব মুছুন';
    case 'te':
      return 'అన్నీ తొలగించు';
    case 'ta':
      return 'அனைத்தையும் அழிக்கவும்';
    case 'ml':
      return 'എല്ലാം ഒഴിവാക്കുക';
    default:
      return 'Clear all';
  }
}

String _getNewBadgeLabel(String lang) {
  switch (lang) {
    case 'hi':
      return 'नया';
    case 'kn':
      return 'ಹೊಸದು';
    case 'mr':
      return 'नवीन';
    case 'pa':
      return 'ਨਵਾਂ';
    case 'bn':
      return 'নতুন';
    case 'te':
      return 'కొత్తది';
    case 'ta':
      return 'புதியது';
    case 'ml':
      return 'പുതിയത്';
    default:
      return 'new';
  }
}

String _getSummaryLabel(int unreadCount, int totalCount, String lang) {
  if (unreadCount > 0) {
    switch (lang) {
      case 'hi':
        return '$unreadCount अपठित · $totalCount कुल';
      case 'kn':
        return '$unreadCount ಓದದಿರುವುದು · $totalCount ಒಟ್ಟು';
      case 'mr':
        return '$unreadCount न वाचलेले · $totalCount एकूण';
      case 'pa':
        return '$unreadCount ਅਣਪੜ੍ਹਿਆ · $totalCount ਕੁੱਲ';
      case 'bn':
        return '$unreadCount অপঠিত · $totalCount মোট';
      case 'te':
        return '$unreadCount చదవనివి · $totalCount మొత్తం';
      case 'ta':
        return '$unreadCount படிக்காதவை · $totalCount மொத்தம்';
      case 'ml':
        return '$unreadCount വായിക്കാത്തത് · $totalCount ആകെ';
      default:
        return '$unreadCount unread · $totalCount total';
    }
  } else {
    switch (lang) {
      case 'hi':
        return '$totalCount कुल';
      case 'kn':
        return '$totalCount ಒಟ್ಟು';
      case 'mr':
        return '$totalCount एकूण';
      case 'pa':
        return '$totalCount ਕੁੱਲ';
      case 'bn':
        return '$totalCount মোট';
      case 'te':
        return '$totalCount మొత్తం';
      case 'ta':
        return '$totalCount மொத்தம்';
      case 'ml':
        return '$totalCount ആകെ';
      default:
        return totalCount == 1 ? '1 notification' : '$totalCount notifications';
    }
  }
}

String _getEmptyTitle(String lang) {
  switch (lang) {
    case 'hi':
      return 'अभी कोई सूचना नहीं है';
    case 'kn':
      return 'ಇನ್ನೂ ಯಾವುದೇ ಅಧಿಸೂಚನೆಗಳಿಲ್ಲ';
    case 'mr':
      return 'अद्याप कोणत्याही अधिसूचना नाहीत';
    case 'pa':
      return 'ਅਜੇ ਤੱਕ ਕੋਈ ਨੋਟੀਫਿਕੇਸ਼ਨ ਨਹੀਂ';
    case 'bn':
      return 'এখনো কোনো বিজ্ঞপ্তি নেই';
    case 'te':
      return 'ఇంకా ఎలాంటి నోటిఫికేషన్‌లు లేవు';
    case 'ta':
      return 'இன்னும் அறிவிப்புகள் எதுவும் இல்லை';
    case 'ml':
      return 'അറിയിപ്പുകൾ ഒന്നും തന്നെയില്ല';
    default:
      return 'No notifications yet';
  }
}

String _getEmptyDesc(String lang) {
  switch (lang) {
    case 'hi':
      return 'बजट अलर्ट, आवर्ती लेनदेन, ऋण ईएमआई और लेजर अनुस्मारक यहां दिखाई देंगे।';
    case 'kn':
      return 'ಬಜೆಟ್ ಎಚ್ಚರಿಕೆಗಳು, ಆವರ್ತक ವಹಿವಾಟುಗಳು, ಸಾಲದ ಇಎಂಐಗಳು ಮತ್ತು ಲೆಡ್ಜರ್ ಜ್ಞಾಪನೆಗಳು ಇಲ್ಲಿ ತೋರಿಸಲ್ಪಡುತ್ತವೆ.';
    case 'mr':
      return 'बजेट अलर्ट, आवर्ती व्यवहार, कर्ज ईएमआय आणि लेजर स्मरणपत्रे येथे दिसतील.';
    case 'pa':
      return 'ਬਜਟ ਅਲਰਟ, ਆਵਰਤੀ ਲੈਣ-ਦੇਣ, ਕਰਜ਼ਾ ਈਐਮਆਈ ਅਤੇ ਲੈਜਰ ਯਾਦ-ਦਹਾਨੀਆਂ ਇੱਥੇ ਦਿਖਾਈ ਦੇਣਗੇ।';
    case 'bn':
      return 'বাজেট সতর্কতা, পৌনঃপুনিক লেনদেন, ঋণ ইএমআই এবং লেজার রিমাইন্ডার এখানে প্রদর্শিত হবে।';
    case 'te':
      return 'బడ్జెట్ అలర్ట్‌లు, ఆవర్తన లావాదేవీలు, రుణ EMIలు మరియు లెడ్జర్ రిమైండర్‌లు ఇక్కడ కనిపిస్తాయి.';
    case 'ta':
      return 'பட்ஜெட் எச்சரிக்கைகள், தொடர் பரிவர்த்தனைகள், கடன் இஎம்ஐ-கள் மற்றும் பேரேடு நினைவூட்டல்கள் இங்கே தோன்றும்.';
    case 'ml':
      return 'ബജറ്റ് അലേർട്ടുകൾ, ആവർത്തിച്ചുള്ള ഇടപാടുകൾ, ലോൺ ഇഎംഐകൾ, ലെഡ്ജർ ഓർമ്മപ്പെടുത്തലുകൾ എന്നിവ ഇവിടെ ദൃശ്യമാകും.';
    default:
      return 'Budget alerts, recurring runs, loan EMIs and ledger reminders will show up here.';
  }
}

extension NotificationTypeMeta on NotificationType {
  IconData get icon => switch (this) {
    NotificationType.general => Icons.notifications_none_rounded,
    NotificationType.budgetAlert => Icons.pie_chart_outline_rounded,
    NotificationType.recurringTransaction => Icons.sync_rounded,
    NotificationType.loanEmi => Icons.account_balance_outlined,
    NotificationType.ledgerReminder => Icons.handshake_outlined,
    NotificationType.backup => Icons.backup_outlined,
    NotificationType.reminderTrigger => Icons.notifications_active_outlined,
  };
}

/// Date-section label for a notification: Today / Yesterday / "5 Jul" /
/// "5 Jul 2025".
String _dateGroupLabel(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(dt.year, dt.month, dt.day);
  final diff = today.difference(day).inDays;
  if (diff == 0) return 'Today';
  if (diff == 1) return 'Yesterday';
  if (dt.year == now.year) return DateFormat('d MMM').format(dt);
  return DateFormat('d MMM yyyy').format(dt);
}

class NotificationsSheet extends StatelessWidget {
  final List<AppNotification> notifications;
  final VoidCallback onClearAll;
  final void Function(AppNotification) onTapNotification;

  const NotificationsSheet({
    super.key,
    required this.notifications,
    required this.onClearAll,
    required this.onTapNotification,
  });

  static Future<void> show(
    BuildContext context, {
    required List<AppNotification> notifications,
    required VoidCallback onClearAll,
    required void Function(AppNotification) onTapNotification,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => NotificationsSheet(
        notifications: notifications,
        onClearAll: onClearAll,
        onTapNotification: onTapNotification,
      ),
    );
  }

  Future<void> _confirmClearAll(BuildContext context) async {
    final cs = Theme.of(context).colorScheme;
    final lang = AppLocale.current.languageCode;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          _getConfirmClearTitle(lang),
          style: localeFont(fontWeight: FontWeight.w700),
        ),
        content: Text(
          _getConfirmClearBody(lang),
          style: localeFont(color: cs.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              context.l10n.cancelLabel,
              style: localeFont(fontWeight: FontWeight.w700),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(
              _getClearAllLabel(lang),
              style: localeFont(fontWeight: FontWeight.w700, color: cs.error),
            ),
          ),
        ],
      ),
    );
    if (ok == true) onClearAll();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final lang = AppLocale.current.languageCode;

    // Sorted most-recent first, grouped by date (Today / Yesterday / date) —
    // no type segregation.
    final sorted = [...notifications]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final dateGroups = <String, List<AppNotification>>{};
    for (final n in sorted) {
      dateGroups.putIfAbsent(_dateGroupLabel(n.createdAt), () => []).add(n);
    }

    final hasAny = notifications.isNotEmpty;
    final unreadCount = notifications.where((n) => n.readAt == null).length;
    final theme = Theme.of(context);

    // Board 3.2d: the shared sheet shell, a summary line with Clear all, day
    // groups as grouped lists; unread rows get a primary wash and a dot.
    return KuberBottomSheet(
      title: context.l10n.menuNotifications,
      description: unreadCount > 0
          ? '$unreadCount ${_getNewBadgeLabel(lang)}'
          : null,
      child: hasAny
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _getSummaryLabel(
                          unreadCount,
                          notifications.length,
                          lang,
                        ),
                        style: theme.textTheme.bodySmall!.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => _confirmClearAll(context),
                      style: TextButton.styleFrom(foregroundColor: cs.error),
                      child: Text(_getClearAllLabel(lang)),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpace.sm),
                for (final entry in dateGroups.entries)
                  _Group(
                    label: entry.key,
                    lang: lang,
                    items: entry.value,
                    onTap: (n) {
                      Navigator.of(context, rootNavigator: true).pop();
                      onTapNotification(n);
                    },
                  ),
              ],
            )
          : KuberEmptyState(
              icon: Icons.notifications_none_rounded,
              title: _getEmptyTitle(lang),
              description: _getEmptyDesc(lang),
            ),
    );
  }
}

/// Date section header + one grouped list of notification rows.
class _Group extends StatelessWidget {
  final String label;
  final String lang;
  final List<AppNotification> items;
  final void Function(AppNotification) onTap;

  const _Group({
    required this.label,
    required this.lang,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: KuberSpace.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          KuberSectionHeader(title: label),
          KuberGroup(
            children: [
              for (final n in items)
                _Row(item: n, lang: lang, onTap: () => onTap(n)),
            ],
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final AppNotification item;
  final String lang;
  final VoidCallback onTap;
  const _Row({required this.item, required this.lang, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final unread = item.readAt == null;
    final tone = item.type == NotificationType.budgetAlert
        ? KuberTone.warning
        : KuberTone.secondary;
    return Material(
      color: unread
          ? cs.primary.withValues(
              alpha: cs.brightness == Brightness.dark ? 0.06 : 0.04,
            )
          : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              KuberIconTile(icon: item.type.icon, tone: tone),
              const SizedBox(width: KuberSpace.lg),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall!.copyWith(
                        color: cs.onSurface,
                      ),
                    ),
                    Text(
                      item.body,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _getGroupTitle(item.type, lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall!.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: KuberSpace.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    DateFormatter.time(item.createdAt),
                    style: theme.textTheme.bodySmall!.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (unread) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
