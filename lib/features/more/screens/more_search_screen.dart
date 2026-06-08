import 'package:kuber/core/utils/locale_font.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../../core/constants/tools_l10n.dart';
import '../../dev/providers/dev_mode_provider.dart';
import '../../settings/widgets/settings_widgets.dart';
import '../../ask_kuber/screen/kuber_mark.dart';
import 'more_screen.dart';


class _SearchableItem {
  final String label;
  final String subtitle;
  final IconData icon;
  final String section;
  final String? route;
  final String? namedRoute;
  final Widget? iconWidget;
  final VoidCallback? onAction;
  final Future<void> Function(BuildContext, WidgetRef)? onRefAction;

  const _SearchableItem({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.section,
    this.route,
    this.namedRoute,
    this.iconWidget,
    this.onAction,
    this.onRefAction,
  });

  bool matches(String q) {
    final lower = q.toLowerCase();
    return label.toLowerCase().contains(lower) ||
        subtitle.toLowerCase().contains(lower);
  }

  void navigate(BuildContext context, WidgetRef ref) {
    if (onRefAction != null) {
      onRefAction!(context, ref);
    } else if (onAction != null) {
      onAction!();
    } else if (namedRoute != null) {
      context.pushNamed(namedRoute!);
    } else {
      context.push(route!);
    }
  }
}

List<_SearchableItem> _buildItems(BuildContext context, String lang, bool isDevMode) => [
  // AI Assistant
  _SearchableItem(
    label: context.l10n.menuAskKuber,
    subtitle: context.l10n.menuAskKuberDesc,
    icon: Icons.auto_awesome_rounded,
    section: context.l10n.askKuber,
    route: '/more/ask-kuber',
    iconWidget: const KuberMarkWidget(size: 20, bare: true),
  ),
  // Manage
  _SearchableItem(
    label: context.l10n.menuAccounts,
    subtitle: context.l10n.menuAccountsDesc,
    icon: Icons.account_balance_wallet_outlined,
    section: context.l10n.moreManageTitle,
    route: '/more/accounts',
  ),
  _SearchableItem(
    label: context.l10n.menuCategories,
    subtitle: context.l10n.menuCategoriesDesc,
    icon: Icons.category_outlined,
    section: context.l10n.moreManageTitle,
    route: '/more/categories',
  ),
  _SearchableItem(
    label: context.l10n.menuTags,
    subtitle: context.l10n.menuTagsDesc,
    icon: Icons.label_outlined,
    section: context.l10n.moreManageTitle,
    route: '/more/tags',
  ),
  _SearchableItem(
    label: context.l10n.menuBudgets,
    subtitle: context.l10n.menuBudgetsDesc,
    icon: Icons.account_balance_rounded,
    section: context.l10n.moreManageTitle,
    route: '/more/budgets',
  ),
  _SearchableItem(
    label: context.l10n.menuRecurring,
    subtitle: context.l10n.menuRecurringDesc,
    icon: Icons.sync_rounded,
    section: context.l10n.moreManageTitle,
    route: '/more/recurring',
  ),
  _SearchableItem(
    label: context.l10n.menuLedger,
    subtitle: context.l10n.menuLedgerDesc,
    icon: Icons.handshake_outlined,
    section: context.l10n.moreManageTitle,
    route: '/more/ledger',
  ),
  _SearchableItem(
    label: context.l10n.menuLoans,
    subtitle: context.l10n.menuLoansDesc,
    icon: Icons.account_balance_outlined,
    section: context.l10n.moreManageTitle,
    route: '/more/loans',
  ),
  _SearchableItem(
    label: context.l10n.menuInvestments,
    subtitle: context.l10n.menuInvestmentsDesc,
    icon: Icons.show_chart,
    section: context.l10n.moreManageTitle,
    route: '/more/investments',
  ),
  // Tools hub
  _SearchableItem(
    label: context.l10n.menuCalculators,
    subtitle: context.l10n.menuCalculatorsDesc,
    icon: Icons.calculate_outlined,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools',
  ),
  _SearchableItem(
    label: context.l10n.menuTutorial,
    subtitle: context.l10n.menuTutorialDesc,
    icon: Icons.school_rounded,
    section: context.l10n.moreTutorialTitle,
    onRefAction: launchTutorialFromMore,
  ),
  _SearchableItem(
    label: context.l10n.menuWelcomeTour,
    subtitle: context.l10n.menuWelcomeTourDesc,
    icon: Icons.auto_stories_rounded,
    section: context.l10n.moreTutorialTitle,
    route: '/onboarding?replay=true',
  ),
  // Individual tools
  _SearchableItem(
    label: tL10n('EMI Calculator', lang),
    subtitle: tL10n('Loan repayments', lang),
    icon: Icons.account_balance_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/emi-calculator',
  ),
  _SearchableItem(
    label: tL10n('Investment Returns', lang),
    subtitle: tL10n('SIP & lump-sum growth', lang),
    icon: Icons.trending_up_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/sip-calculator',
  ),
  _SearchableItem(
    label: tL10n('SIP Amount', lang),
    subtitle: tL10n('Find monthly investment', lang),
    icon: Icons.savings_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/sip-amount-finder',
  ),
  _SearchableItem(
    label: tL10n('FD / RD', lang),
    subtitle: tL10n('Fixed & recurring deposits', lang),
    icon: Icons.account_balance_wallet_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/fd-rd-calculator',
  ),
  _SearchableItem(
    label: tL10n('PPF Calculator', lang),
    subtitle: tL10n('15-year provident fund', lang),
    icon: Icons.shield_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/ppf-calculator',
  ),
  _SearchableItem(
    label: tL10n('Inflation', lang),
    subtitle: tL10n('Future purchasing power', lang),
    icon: Icons.trending_down_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/inflation-calculator',
  ),
  _SearchableItem(
    label: tL10n('Salary Breakdown', lang),
    subtitle: tL10n('CTC → in-hand', lang),
    icon: Icons.work_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/salary-calculator',
  ),
  _SearchableItem(
    label: tL10n('GST Calculator', lang),
    subtitle: tL10n('Add or remove GST', lang),
    icon: Icons.percent_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/gst-calculator',
  ),
  _SearchableItem(
    label: tL10n('HRA Exemption', lang),
    subtitle: tL10n('Old regime tax', lang),
    icon: Icons.home_work_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/hra-calculator',
  ),
  _SearchableItem(
    label: tL10n('Tip Calculator', lang),
    subtitle: tL10n('Bills & gratuity', lang),
    icon: Icons.receipt_long_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/tip-calculator',
  ),
  _SearchableItem(
    label: tL10n('Discount Calculator', lang),
    subtitle: tL10n('Find the best deal', lang),
    icon: Icons.local_offer_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/discount-calculator',
  ),
  _SearchableItem(
    label: tL10n('Break-even', lang),
    subtitle: tL10n('Months to recover', lang),
    icon: Icons.timeline_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/breakeven-calculator',
  ),
  _SearchableItem(
    label: tL10n('Split Calculator', lang),
    subtitle: tL10n('Split expenses between people', lang),
    icon: Icons.people_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/split-calculator',
  ),
  _SearchableItem(
    label: tL10n('Currency Converter', lang),
    subtitle: tL10n('Convert currencies', lang),
    icon: Icons.currency_exchange_rounded,
    section: context.l10n.moreToolsTitle,
    route: '/more/tools/currency-converter',
  ),
  // App
  _SearchableItem(
    label: context.l10n.menuSettings,
    subtitle: context.l10n.menuSettingsDesc,
    icon: Icons.settings_outlined,
    section: context.l10n.moreAppTitle,
    route: '/more/settings',
  ),
  _SearchableItem(
    label: context.l10n.menuData,
    subtitle: context.l10n.menuDataDesc,
    icon: Icons.storage_rounded,
    section: context.l10n.moreAppTitle,
    route: '/more/data',
  ),
  _SearchableItem(
    label: context.l10n.menuStoriesArchive,
    subtitle: context.l10n.menuStoriesArchiveDesc,
    icon: Icons.auto_stories_rounded,
    section: context.l10n.moreAppTitle,
    route: '/more/stories-archive',
  ),
  _SearchableItem(
    label: context.l10n.menuTroubleshoot,
    subtitle: context.l10n.menuTroubleshootDesc,
    icon: Icons.build_outlined,
    section: context.l10n.moreAppTitle,
    route: '/more/troubleshoot',
  ),
  // About
  _SearchableItem(
    label: context.l10n.menuAbout,
    subtitle: context.l10n.menuAboutDesc,
    icon: Icons.info_outline_rounded,
    section: context.l10n.moreAboutTitle,
    namedRoute: 'about',
  ),
  _SearchableItem(
    label: context.l10n.menuPermissions,
    subtitle: context.l10n.menuPermissionsDesc,
    icon: Icons.security_outlined,
    section: context.l10n.moreAboutTitle,
    namedRoute: 'permissions',
  ),
  // Contact Us
  _SearchableItem(
    label: context.l10n.menuRateUs,
    subtitle: context.l10n.menuRateUsDesc,
    icon: Icons.star_rate_rounded,
    section: context.l10n.moreHelpUsTitle,
    onAction: () => launchUrl(
      Uri.parse('https://play.google.com/store/apps/details?id=com.grs.kuber'),
      mode: LaunchMode.externalApplication,
    ),
  ),
  _SearchableItem(
    label: context.l10n.menuShareApp,
    subtitle: context.l10n.menuShareAppDesc,
    icon: Icons.share_rounded,
    section: context.l10n.moreHelpUsTitle,
    onAction: () => SharePlus.instance.share(
      ShareParams(
        text: context.l10n.shareMessage,
      ),
    ),
  ),
  _SearchableItem(
    label: context.l10n.menuFeedback,
    subtitle: context.l10n.menuFeedbackDesc,
    icon: Icons.feedback_outlined,
    section: context.l10n.moreHelpUsTitle,
    route: '/more/feedback',
  ),
  // Dev Tools (conditional)
  if (isDevMode)
    _SearchableItem(
      label: context.l10n.menuDevTools,
      subtitle: context.l10n.menuDevToolsDesc,
      icon: Icons.bug_report_outlined,
      section: context.l10n.menuDevTools,
      route: '/more/dev-tools',
    ),
];

class MoreSearchScreen extends ConsumerStatefulWidget {
  const MoreSearchScreen({super.key});

  @override
  ConsumerState<MoreSearchScreen> createState() => _MoreSearchScreenState();
}

class _MoreSearchScreenState extends ConsumerState<MoreSearchScreen> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  String _query = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
    _controller.addListener(() {
      setState(() => _query = _controller.text);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _noResultsLabel(String query, String lang) {
    switch (lang) {
      case 'hi':
        return '"$query" के लिए कोई परिणाम नहीं';
      case 'kn':
        return '"$query" ಗೆ ಯಾವುದೇ ಫಲಿತಾಂಶಗಳಿಲ್ಲ';
      case 'ml':
        return '"$query" എന്നതിനായി ഫലങ്ങളൊന്നുമില്ല';
      case 'ta':
        return '"$query" க்கான முடிவுகள் இல்லை';
      case 'te':
        return '"$query" కోసం ఫలితాలు లేవు';
      case 'mr':
        return '"$query" साठी कोणतेही परिणाम नाहीत';
      case 'bn':
        return '"$query"-এর জন্য কোনো ফলাফল পাওয়া যায়নি';
      case 'pa':
        return '"$query" ਲਈ ਕੋਈ ਨਤੀਜਾ ਨਹੀਂ ਮਿਲਿਆ';
      default:
        return 'No results for "$query"';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDevMode = ref.watch(devModeProvider).valueOrNull ?? false;
    final lang = Localizations.localeOf(context).languageCode;
    final allItems = _buildItems(context, lang, isDevMode);
    final filtered = _query.isEmpty
        ? allItems
        : allItems.where((item) => item.matches(_query)).toList();

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        child: Column(
          children: [
            // Search bar row
            Padding(
              padding: const EdgeInsets.fromLTRB(
                KuberSpacing.lg,
                KuberSpacing.md,
                KuberSpacing.lg,
                KuberSpacing.md,
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Icon(
                      Icons.arrow_back_rounded,
                      color: cs.onSurface,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: KuberSpacing.md),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      focusNode: _focusNode,
                      style: localeFont(
                        fontSize: 14,
                        color: cs.onSurface,
                      ),
                      decoration: InputDecoration(
                        hintText: '${context.l10n.search}...',
                        hintStyle: localeFont(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: cs.onSurfaceVariant,
                          size: 20,
                        ),
                        suffixIcon: _query.isNotEmpty
                            ? GestureDetector(
                                onTap: () {
                                  _controller.clear();
                                  _focusNode.requestFocus();
                                },
                                child: Icon(
                                  Icons.close_rounded,
                                  color: cs.onSurfaceVariant,
                                  size: 18,
                                ),
                              )
                            : null,
                        filled: true,
                        fillColor: cs.surfaceContainer,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: KuberSpacing.md,
                          horizontal: KuberSpacing.lg,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                          borderSide: BorderSide(color: cs.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                          borderSide: BorderSide(color: cs.outline),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(KuberRadius.md),
                          borderSide: BorderSide(color: cs.outline),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: cs.outline),

            // Results list
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Text(
                        _noResultsLabel(_query, lang),
                        style: localeFont(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) =>
                          Divider(height: 1, color: cs.outline, indent: 52),
                      itemBuilder: (context, index) =>
                          _SearchResultItem(item: filtered[index]),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResultItem extends ConsumerWidget {
  final _SearchableItem item;

  const _SearchResultItem({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => item.navigate(context, ref),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.md,
        ),
        child: Row(
          children: [
            SquircleIcon(icon: item.icon, glyph: item.iconWidget),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: localeFont(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: cs.primaryContainer,
                          borderRadius: BorderRadius.circular(KuberRadius.sm),
                        ),
                        child: Text(
                          item.section,
                          style: localeFont(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: cs.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          item.subtitle,
                          style: localeFont(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: cs.onSurfaceVariant.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}