import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:kuber/core/utils/locale_font.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/services/shortcut_pin_service.dart';
import '../../../core/services/notification_service.dart' show KuberChannel, NotificationService;
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/brand_icon.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/kuber_bottom_sheet.dart';
import '../../../shared/widgets/kuber_list.dart';
import '../../../shared/widgets/kuber_form_widgets.dart' show KuberInfoGlyph;
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../home_v2/data/home_v2_state.dart';
import '../../home_v2/providers/home_v2_provider.dart';
import '../../kuber_cards/data/card_biometric.dart';
import '../../kuber_cards/providers/kuber_cards_provider.dart';
import '../../more/more_content.dart' show openNotificationsSheet;
import '../../more/screens/more_screen.dart' show launchTutorialFromMore;
import '../../more/widgets/more_tab_layout_picker.dart';
import '../../notes/providers/notes_provider.dart';
import '../../widget_editor/models/home_widget_config.dart';
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/currency_selector_sheet.dart';
import '../widgets/settings_anchor.dart';
import '../widgets/settings_choice_sheet.dart';
import '../widgets/settings_language_row.dart';
import '../widgets/settings_section.dart';
import '../widgets/text_size_sheet.dart';

// The pages Settings opens. Rows, stored keys and behaviour are the ones the
// long Settings page had; each row carries its search id (settings_index.dart).

Widget _trailing(BuildContext context, {String? text, IconData icon = Icons.chevron_right_rounded}) {
  final cs = Theme.of(context).colorScheme;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (text != null && text.isNotEmpty) ...[
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: KuberSpace.lg),
      ],
      Icon(icon, color: cs.onSurfaceVariant, size: 20),
    ],
  );
}


void _showBottomNavSheet(BuildContext context, WidgetRef ref, NavBarStyle current) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SettingsChoiceSheet<NavBarStyle>(
      title: context.l10n.bottomNavLabel,
      subtitle: context.l10n.appearanceCategory,
      selectedValue: current,
      choices: [
        SettingsChoice(
          value: NavBarStyle.classic,
          label: context.l10n.setNavStandard,
          subtitle: context.l10n.navSubtitleClassic,
          icon: Icons.view_headline_rounded,
        ),
        SettingsChoice(
          value: NavBarStyle.modern,
          label: context.l10n.setNavFloating,
          subtitle: context.l10n.navSubtitleModern,
          icon: Icons.lens_rounded,
        ),
      ],
      onSelected: (val) {
        ref.read(settingsProvider.notifier).setNavBarStyle(val);
      },
    ),
  );
}


void _showMoreTabLayoutSheet(BuildContext context, WidgetRef ref, MoreTabLayout current) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SettingsChoiceSheet<MoreTabLayout>(
      title: context.l10n.moreTabLayoutLabel,
      subtitle: context.l10n.appearanceCategory,
      selectedValue: current,
      choices: moreTabLayoutChoices(context),
      onSelected: (val) {
        ref.read(settingsProvider.notifier).setMoreTabLayout(val);
      },
    ),
  );
}


void _showNumberFormatSheet(BuildContext context, WidgetRef ref, NumberSystem current) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SettingsChoiceSheet<NumberSystem>(
      title: context.l10n.numberFormatLabel,
      subtitle: context.l10n.moneyDisplayCategory,
      selectedValue: current,
      choices: [
        SettingsChoice(
          value: NumberSystem.automatic,
          label: context.l10n.numFormatAutomatic,
          subtitle: context.l10n.numFormatAutomaticSub,
          icon: Icons.auto_awesome_outlined,
        ),
        SettingsChoice(
          value: NumberSystem.indian,
          label: context.l10n.setNumLakh,
          subtitle: '1,23,000.00',
          icon: Icons.language_rounded,
        ),
        SettingsChoice(
          value: NumberSystem.international,
          label: context.l10n.setNumMillion,
          subtitle: '123,000.00',
          icon: Icons.public_rounded,
        ),
      ],
      onSelected: (val) {
        ref.read(settingsProvider.notifier).setNumberSystem(val);
      },
    ),
  );
}


void _showDefaultAccountPicker(
  BuildContext context,
  WidgetRef ref,
  List<Account> accounts,
  String? currentId,
) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
    shape: RoundedRectangleBorder(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(KuberShape.extraLarge),
      ),
      side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (ctx, scrollController) {
          return Column(
            children: [
              const SizedBox(height: KuberSpace.md),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(KuberShape.full),
                ),
              ),
              const SizedBox(height: KuberSpace.lg),
              Text(
                context.l10n.defaultAccountLabel,
                style: localeFont(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: cs.onSurface,
                ),
              ),
              const SizedBox(height: KuberSpace.lg),
              if (accounts.isEmpty)
                Padding(
                  padding: const EdgeInsets.all(KuberSpace.xl),
                  child: Text(
                    context.l10n.noAccountsFound,
                    style: localeFont(color: cs.onSurfaceVariant),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: accounts.length,
                    itemBuilder: (ctx, i) {
                      final a = accounts[i];
                      final isSelected = a.id.toString() == currentId;
                      return ListTile(
                        leading: CategoryIcon.square(
                          icon: a.icon != null
                              ? IconMapper.fromString(a.icon!)
                              : Icons.account_balance,
                          rawColor: a.colorValue != null
                              ? Color(a.colorValue!)
                              : cs.primary,
                          size: 44,
                        ),
                        title: Text(
                          a.name,
                          style: localeFont(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w400,
                            color: cs.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          a.isCreditCard
                              ? context.l10n.creditCardLabel
                              : a.isOverdraft
                              ? context.l10n.accountTypeOverdraft
                              : context.l10n.bankCashLabel,
                          style: localeFont(
                            fontSize: 12,
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                color: cs.primary,
                                size: 20,
                              )
                            : null,
                        onTap: () {
                          ref
                              .read(settingsProvider.notifier)
                              .setDefaultAccountId(a.id.toString());
                          Navigator.pop(ctx);
                          showKuberSnackBar(
                            context,
                            context.l10n.setAsDefault(a.name),
                          );
                        },
                      );
                    },
                  ),
                ),
              if (currentId != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    KuberSpace.lg,
                    KuberSpace.sm,
                    KuberSpace.lg,
                    KuberSpace.lg,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        ref
                            .read(settingsProvider.notifier)
                            .setDefaultAccountId(null);
                        Navigator.pop(ctx);
                        showKuberSnackBar(
                          context,
                          context.l10n.defaultAccountCleared,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: cs.error,
                        side: BorderSide(
                          color: cs.error.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            KuberShape.medium,
                          ),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        context.l10n.clearDefault,
                        style: localeFont(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      );
    },
  );
}


/// Runs [onResume] when the page opens and when the user comes back to the app
/// (from phone settings).
class SettingsOnResume extends StatefulWidget {
  final VoidCallback onResume;
  final Widget child;
  const SettingsOnResume({required this.onResume, required this.child});

  @override
  State<SettingsOnResume> createState() => _SettingsOnResumeState();
}

class _SettingsOnResumeState extends State<SettingsOnResume> {
  late final _listener = AppLifecycleListener(onResume: () => widget.onResume());

  @override
  void initState() {
    super.initState();
    _listener;
    // Also on open: the permission may have been granted from another screen
    // (Welcome, Permissions, a reminder) since the value was cached.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onResume();
    });
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// "today", "yesterday" or "3 days ago".
String backupAgo(AppLocalizations l, DateTime at) {
  final days = DateUtils.dateOnly(DateTime.now()).difference(DateUtils.dateOnly(at)).inDays;
  return days <= 0 ? l.todayLower : l.daysAgo(days);
}

/// Theme mode as a word.
String themeModeName(AppLocalizations l, ThemeMode mode) => switch (mode) {
      ThemeMode.light => l.themeLightChoice,
      ThemeMode.dark => l.themeDarkChoice,
      ThemeMode.system => l.themeSystemChoice,
    };

/// "Lakh", "Million" or "Automatic".
String numberSystemName(AppLocalizations l, NumberSystem n) => switch (n) {
      NumberSystem.indian => l.setNumLakh,
      NumberSystem.international => l.setNumMillion,
      NumberSystem.automatic => l.numFormatAutomatic,
    };

/// Look and feel: theme, text size, layouts, Home and Analytics widgets.
class LookAndFeelScreen extends ConsumerWidget {
  final String? highlight;
  const LookAndFeelScreen({super.key, this.highlight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final mode = ref.watch(themeModeProvider);
    final variant = ref.watch(themeVariantProvider);
    final nav = ref.watch(settingsProvider.select((s) => s.valueOrNull?.navBarStyle ?? NavBarStyle.modern));
    final layout = ref.watch(moreTabLayoutProvider);
    final homeWidgets = ref.watch(homeWidgetsProvider).valueOrNull ?? <HomeWidgetConfig>[];
    final analyticsWidgets = ref.watch(analyticsWidgetsProvider).valueOrNull ?? <HomeWidgetConfig>[];
    return SettingsPageFrame(
      title: l.setGroupLook,
      highlight: highlight,
      children: [
        SettingsBlock(
          children: [
            SettingsAnchor('theme', child: SettingsTile(
              icon: Icons.contrast_rounded,
              label: l.themeLabel,
              subtitle: '${themeFamilyName(variant)} · ${themeModeName(l, mode)}',
              onTap: () => context.push('/more/settings/theme'),
              trailing: _trailing(context),
            )),
            SettingsAnchor('textSize', child: SettingsTile(
              icon: Icons.format_size_rounded,
              label: l.textSizeTitle,
              subtitle: l.textSizeDesc,
              onTap: () => TextSizeSheet.show(context),
              trailing: _trailing(context, text: textSizeLabel(context, ref.watch(textSizeLevelProvider))),
            )),
            SettingsAnchor('bottomNav', child: SettingsTile(
              icon: Icons.space_dashboard_outlined,
              label: l.setBottomNav,
              subtitle: l.bottomNavSubtitle,
              onTap: () => _showBottomNavSheet(context, ref, nav),
              trailing: _trailing(context, text: nav == NavBarStyle.classic ? l.setNavStandard : l.setNavFloating),
            )),
            SettingsAnchor('moreLayout', child: SettingsTile(
              icon: Icons.grid_view_outlined,
              label: l.setMoreLayout,
              subtitle: l.setMoreLayoutSub,
              onTap: () => _showMoreTabLayoutSheet(context, ref, layout),
              trailing: _trailing(context, text: layout == MoreTabLayout.simple ? l.simpleLabel : l.setLayoutHero),
            )),
          ],
        ),
        SettingsBlock(
          title: l.setSecHomeAnalytics,
          children: [
            SettingsAnchor('homeWidgets', child: SettingsTile(
              icon: Icons.home_outlined,
              label: l.setHomeWidgets,
              subtitle: l.setWidgetsOn('${homeWidgets.where((w) => w.enabled).length}'),
              onTap: () => context.push('/widget-editor/home'),
              trailing: _trailing(context),
            )),
            SettingsAnchor('analyticsWidgets', child: SettingsTile(
              icon: Icons.insert_chart_outlined_rounded,
              label: l.setAnalyticsWidgets,
              subtitle: l.setWidgetsOn('${analyticsWidgets.where((w) => w.enabled).length}'),
              onTap: () => context.push('/widget-editor/analytics'),
              trailing: _trailing(context),
            )),
            // Home v2 installs only (board HV2.2 Settings).
            ...const _HomeV2SettingsRows().rows(context, ref),
            SettingsAnchor('gallery', child: SettingsTile(
              icon: Icons.widgets_outlined,
              label: l.setHomeScreenWidgets,
              subtitle: l.setGallerySub,
              onTap: () => context.push('/more/widgets-gallery'),
              trailing: _trailing(context),
            )),
          ],
        ),
      ],
    );
  }
}

/// App preferences: shortcuts, language, money format, default account, swipe.
class AppPreferencesScreen extends ConsumerWidget {
  final String? highlight;
  const AppPreferencesScreen({super.key, this.highlight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider).valueOrNull;
    final accounts = ref.watch(accountListProvider).valueOrNull ?? <Account>[];
    final defaultAccId = settings?.defaultAccountId;
    final defaultAccName =
        accounts.where((a) => a.id.toString() == defaultAccId).firstOrNull?.name ?? l.notSet;
    final currencyCode = settings?.currency ?? 'INR';
    final currency = currencyFromCode(currencyCode);
    final numberSystem = settings?.numberSystem ?? NumberSystem.automatic;
    final swipe = settings?.swipeMode ?? SwipeMode.changeTabs;
    final numberStr = numberSystemName(l, numberSystem);
    return SettingsPageFrame(
      title: l.setGroupPrefs,
      highlight: highlight,
      children: [
        SettingsBlock(
          title: l.setSecShortcuts,
          children: [
            SettingsAnchor('quickActions', child: SettingsTile(
              icon: Icons.bolt_outlined,
              label: l.setQuickActions,
              subtitle: l.setQuickActionsSub,
              onTap: () => context.push('/settings/quick-actions'),
              trailing: _trailing(context),
            )),
            SettingsAnchor('addMenu', child: SettingsTile(
              icon: Icons.add_circle_outline_rounded,
              label: l.setAddMenu,
              subtitle: l.setAddMenuSub,
              onTap: () => context.push('/settings/add-menu'),
              trailing: _trailing(context),
            )),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(top: 0, bottom: KuberSpace.sectionGap),
          child: KuberInfoLine(text: l.setPathTip),
        ),
        SettingsBlock(
          title: l.setSecMoney,
          children: [
            const SettingsAnchor('language', child: SettingsLanguageRow()),
            SettingsAnchor('currency', child: SettingsTile(
              icon: Icons.currency_rupee_rounded,
              label: l.currencyLabel,
              subtitle: l.setCurrencySub,
              // Currency selection is free for everyone.
              onTap: () => showCurrencyPicker(context: context, ref: ref, currentCode: currencyCode, onSelected: (_) {}),
              trailing: _trailing(context, text: '${currency.symbol} ${currency.code}'),
            )),
            SettingsAnchor('numberFormat', child: SettingsTile(
              icon: Icons.pin_rounded,
              label: l.setNumberFormat,
              subtitle: switch (numberSystem) {
                NumberSystem.indian => '$numberStr · 1,23,456',
                NumberSystem.international => '$numberStr · 123,456',
                NumberSystem.automatic => l.numFormatAutomaticSub,
              },
              onTap: () => _showNumberFormatSheet(context, ref, numberSystem),
              trailing: _trailing(context, text: numberStr),
            )),
            SettingsAnchor('currencyCode', child: SettingsTile(
              icon: Icons.abc_rounded,
              label: l.setShowCode,
              subtitle: l.setShowCodeSub(
                AppFormatter(currency: currency, showCode: true).formatCurrency(500),
                AppFormatter(currency: currency).formatCurrency(500),
              ),
              trailing: Switch(
                value: settings?.showCurrencyCode ?? false,
                onChanged: (v) => ref.read(settingsProvider.notifier).setShowCurrencyCode(v),
                activeTrackColor: cs.primary,
              ),
            )),
            SettingsAnchor('defaultAccount', child: SettingsTile(
              icon: Icons.account_balance_outlined,
              label: l.setDefaultAccount,
              subtitle: l.setDefaultAccountSub,
              onTap: () => _showDefaultAccountPicker(context, ref, accounts, defaultAccId),
              trailing: _trailing(context, text: defaultAccName),
            )),
          ],
        ),
        SettingsBlock(
          title: l.setSecGestures,
          children: [
            SettingsAnchor('swipe', child: SettingsTile(
              icon: Icons.swipe_rounded,
              label: l.setSwipe,
              subtitle: l.setSwipeSub,
              trailing: Switch(
                value: swipe == SwipeMode.changeTabs,
                onChanged: (v) => ref
                    .read(settingsProvider.notifier)
                    .setSwipeMode(v ? SwipeMode.changeTabs : SwipeMode.performActions),
                activeTrackColor: cs.primary,
              ),
            )),
          ],
        ),
      ],
    );
  }
}

/// Whether this phone can unlock with a fingerprint or face right now.
final biometricEnrolledProvider = FutureProvider.autoDispose<bool>((ref) async {
  final bio = BiometricService();
  return await bio.canAuthenticate() && await bio.hasEnrolled();
});

/// Privacy and security. The app lock and the Kuber Cards biometric are two
/// settings: each has its own switch and check, and neither touches the other.
class PrivacySecurityScreen extends ConsumerStatefulWidget {
  final String? highlight;
  const PrivacySecurityScreen({super.key, this.highlight});

  @override
  ConsumerState<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  final _biometric = BiometricService();

  Future<void> _setAppLock(bool val) async {
    final l = context.l10n;
    final notifier = ref.read(settingsProvider.notifier);
    if (val) {
      // Only authenticate if turning ON
      if (!await _biometric.canAuthenticate()) {
        if (mounted) showKuberSnackBar(context, l.biometricNotAvailable, isError: true);
        return;
      }
      if (!await _biometric.authenticate()) {
        if (!await _biometric.hasEnrolled() && mounted) {
          showKuberSnackBar(context, l.biometricNotAvailable, isError: true);
        }
        return;
      }
      await notifier.setBiometricsEnabled(true);
      if (mounted) showKuberSnackBar(context, l.biometricEnabledMsg);
    } else {
      // Require authentication before disabling biometric lock
      if (!await _biometric.authenticate()) return;
      await notifier.setBiometricsEnabled(false);
      if (mounted) showKuberSnackBar(context, l.biometricDisabledMsg);
    }
  }

  void _showLocksSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final l = ctx.l10n;
        final theme = Theme.of(ctx);
        final cs = theme.colorScheme;
        final body = theme.textTheme.bodyLarge!.copyWith(color: cs.onSurfaceVariant);
        Widget line(String lead, String rest) => Padding(
              padding: const EdgeInsets.only(bottom: KuberSpace.lg),
              child: Text.rich(
                TextSpan(
                  style: body,
                  children: [
                    TextSpan(text: lead, style: body.copyWith(color: cs.onSurface, fontWeight: FontWeight.w700)),
                    TextSpan(text: ' $rest'),
                  ],
                ),
              ),
            );
        return KuberBottomSheet(
          title: l.setLocksTitle,
          actions: AppButton(
            label: l.setGotIt,
            type: AppButtonType.primary,
            fullWidth: true,
            onPressed: () => Navigator.of(ctx).pop(),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              line(l.setAppLock, l.setLocksApp),
              line(l.appDrawerCards, l.setLocksCards),
              Text(l.setLocksNeither, style: body),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final appLock = ref.watch(settingsProvider.select((s) => s.valueOrNull?.biometricsEnabled ?? false));
    final meta = ref.watch(cardVaultMetaProvider).valueOrNull;
    final hasVault = meta != null;
    final noBiometric = ref.watch(biometricEnrolledProvider).valueOrNull == false;
    // With nothing enrolled a switch that is on must still turn off.
    final lockOff = noBiometric && !appLock;
    final cardsOff = noBiometric && !(meta?.biometricEnabled ?? false);
    return SettingsOnResume(
      onResume: () => ref.invalidate(biometricEnrolledProvider),
      child: SettingsPageFrame(
        title: l.setGroupPrivacy,
        highlight: widget.highlight,
        children: [
          if (noBiometric)
            Container(
              margin: const EdgeInsets.only(bottom: KuberSpace.lg),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(KuberShape.large),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.fingerprint_rounded, size: 20, color: cs.onSurfaceVariant),
                      const SizedBox(width: KuberSpace.md),
                      Expanded(
                        child: Text(l.setNoFp, style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurface)),
                      ),
                    ],
                  ),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: TextButton(onPressed: openSecuritySettings, child: Text(l.setNoFpOpen)),
                  ),
                ],
              ),
            ),
          SettingsBlock(
            children: [
              SettingsAnchor('privacyMode', child: SettingsTile(
                icon: Icons.visibility_off_outlined,
                label: l.setPrivacyMode,
                subtitle: l.setPrivacyModeSub,
                trailing: Switch(
                  value: ref.watch(privacyModeProvider),
                  onChanged: (_) => ref.read(settingsProvider.notifier).togglePrivacyMode(),
                  activeTrackColor: cs.primary,
                ),
              )),
              SettingsAnchor('biometric', child: SettingsTile(
                icon: Icons.lock_outline_rounded,
                label: l.setAppLock,
                subtitle: lockOff ? l.setAppLockNoFp : l.setAppLockSub,
                disabled: lockOff,
                trailing: Switch(
                  value: appLock,
                  onChanged: lockOff ? null : _setAppLock,
                  activeTrackColor: cs.primary,
                ),
              )),
            ],
          ),
          // Shown once a vault exists: there is nothing to protect or change
          // until the user has set up Kuber Cards.
          if (hasVault)
            SettingsBlock(
              title: l.appDrawerCards,
              inline: [KuberInfoGlyph(onTap: _showLocksSheet)],
              children: [
                SettingsAnchor('cardsBiometric', child: SettingsTile(
                  icon: Icons.fingerprint_rounded,
                  label: l.setCardsFp,
                  subtitle: cardsOff ? l.setCardsFpNone : l.setCardsFpSub,
                  disabled: cardsOff,
                  trailing: Switch(
                    value: meta.biometricEnabled,
                    onChanged: cardsOff
                        ? null
                        : (v) => toggleCardBiometric(context, ref, v,
                            onNeedsUnlock: () => context.push('/cards')),
                    activeTrackColor: cs.primary,
                  ),
                )),
                SettingsAnchor('cardsPin', child: SettingsTile(
                  icon: Icons.password_rounded,
                  label: l.setCardsPinRow,
                  subtitle: l.setCardsPinRowSub,
                  trailing: _trailing(context),
                  // Kuber Cards is free up to 2 cards, so managing the unlock
                  // PIN is free too. No entry-level Pro gate.
                  onTap: () => context.push('/cards/change-pin'),
                )),
              ],
            ),
          SettingsBlock(
            title: l.appDrawerNotes,
            children: [
              // Notes-specific gate. Greyed out until the app lock above is on
              // (per design 1l).
              SettingsAnchor('notesBiometric', child: SettingsTile(
                icon: Icons.sticky_note_2_outlined,
                label: l.setNotesLock,
                subtitle: appLock ? l.setNotesLockOn : l.setNotesLockOff,
                disabled: !appLock,
                trailing: Switch(
                  value: appLock && ref.watch(notesBiometricRequiredProvider),
                  onChanged: !appLock
                      ? null
                      : (val) async {
                          await ref.read(notesBiometricRequiredProvider.notifier).set(val);
                          if (!val) {
                            ref.read(notesUnlockedThisSessionProvider.notifier).state = false;
                          }
                        },
                  activeTrackColor: cs.primary,
                ),
              )),
            ],
          ),
          if (hasVault) KuberInfoLine(text: l.setLocksInfo),
        ],
      ),
    );
  }
}

/// App drawer (Android): own launcher icons for three screens.
class AppDrawerScreen extends ConsumerWidget {
  final String? highlight;
  const AppDrawerScreen({super.key, this.highlight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final on = ref.watch(appDrawerEntriesProvider).valueOrNull ?? const <AppDrawerEntry>{};
    Widget preview(IconData? icon, String label, bool lit) => Opacity(
          opacity: lit ? 1 : 0.38,
          child: SizedBox(
            width: 64,
            child: Column(
              children: [
                // Kuber is the launcher icon itself, in the theme's tones.
                if (icon == null)
                  const BrandIcon(size: 52, radius: 26)
                else
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: cs.secondaryContainer,
                      shape: BoxShape.circle,
                      border: lit ? null : Border.all(color: cs.outline, width: 1.5),
                    ),
                    child: Icon(icon, size: 26, color: cs.onSecondaryContainer),
                  ),
                const SizedBox(height: 6),
                Text(label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall!.copyWith(color: cs.onSurface)),
              ],
            ),
          ),
        );
    return SettingsPageFrame(
      title: l.appDrawerSection,
      highlight: highlight,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: KuberSpace.lg),
          child: Text(l.setDrawerBody, style: theme.textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
          child: KuberCard(
            color: cs.surfaceContainerLow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l.setDrawerPreview.toUpperCase(), style: sectionHeaderStyle(context)),
                const SizedBox(height: KuberSpace.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    preview(null, 'Kuber', true),
                    for (final (e, icon, label) in [
                      (AppDrawerEntry.cards, Icons.credit_card_rounded, l.appDrawerCards),
                      (AppDrawerEntry.notes, Icons.sticky_note_2_rounded, l.appDrawerNotes),
                      (AppDrawerEntry.reminders, Icons.alarm_rounded, l.appDrawerReminders),
                    ])
                      preview(icon, label, on.contains(e)),
                  ],
                ),
              ],
            ),
          ),
        ),
        SettingsBlock(
          children: [
            for (final (e, id, icon, label) in [
              (AppDrawerEntry.cards, 'drawerCards', Icons.credit_card_rounded, l.appDrawerCards),
              (AppDrawerEntry.notes, 'drawerNotes', Icons.sticky_note_2_outlined, l.appDrawerNotes),
              (AppDrawerEntry.reminders, 'drawerReminders', Icons.alarm_rounded, l.appDrawerReminders),
            ])
              SettingsAnchor(id, child: SettingsTile(
                icon: icon,
                label: label,
                subtitle: l.setDrawerRowSub,
                trailing: Switch(
                  value: on.contains(e),
                  onChanged: (v) => toggleAppDrawerEntry(context, ref, e, v),
                  activeTrackColor: cs.primary,
                ),
              )),
          ],
        ),
      ],
    );
  }
}

/// Whether the system lets Kuber post notifications. Read on opening the page
/// and when the user comes back from system settings.
final notificationsAllowedProvider =
    FutureProvider<bool>((ref) async => (await Permission.notification.status).isGranted);

/// Which of Kuber's notification categories are on in the phone's settings.
/// Read with [notificationsAllowedProvider]: on opening and on coming back.
final notificationChannelsProvider =
    FutureProvider<Map<KuberChannel, bool>>((ref) => NotificationService().channelStates());

/// Asks the system, or opens system settings once it has been refused.
Future<bool> requestNotifications() async {
  final status = await Permission.notification.request();
  if (status.isPermanentlyDenied) await openNotificationSettings();
  return status.isGranted;
}

/// Notifications: the current state, what Kuber sends, and the inbox. Each
/// category's on or off lives in the phone's settings only; a row shows it
/// and opens it there.
class NotificationsSettingsScreen extends ConsumerWidget {
  final String? highlight;
  const NotificationsSettingsScreen({super.key, this.highlight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final allowed = ref.watch(notificationsAllowedProvider).valueOrNull ?? true;
    final channels = ref.watch(notificationChannelsProvider).valueOrNull ?? const {};
    return SettingsOnResume(
      onResume: () => ref
        ..invalidate(notificationsAllowedProvider)
        ..invalidate(notificationChannelsProvider),
      child: SettingsPageFrame(
        title: l.menuNotifications,
        highlight: highlight,
        children: [
          SettingsAnchor('notifPermission', child: allowed
              ? SettingsBlock(
                  children: [
                    SettingsTile(
                      icon: Icons.notifications_active_outlined,
                      label: l.setNotifAllowed,
                      subtitle: l.setNotifAllowedShort,
                      onTap: openNotificationSettings,
                      trailing: Icon(Icons.open_in_new_rounded, size: 20, color: cs.onSurfaceVariant),
                    ),
                  ],
                )
              : Padding(
                  padding: const EdgeInsets.only(bottom: KuberSpace.sectionGap),
                  child: KuberStatusBanner(
                    icon: Icons.notifications_off_outlined,
                    title: l.setNotifBlocked,
                    body: l.setNotifOffBody,
                    actionLabel: l.setTurnOn,
                    onAction: openNotificationSettings,
                  ),
                )),
          SettingsBlock(
            title: l.setSecSends,
            children: [
              for (final (channel, id, icon) in const [
                (KuberChannel.payments, 'notifEmi', Icons.event_repeat_rounded),
                (KuberChannel.budgets, 'notifBudget', Icons.donut_large_rounded),
                (KuberChannel.reminders, 'notifReminders', Icons.alarm_rounded),
                (KuberChannel.ledger, 'notifLedger', Icons.handshake_outlined),
                (KuberChannel.backups, 'notifBackup', Icons.backup_outlined),
              ])
                SettingsAnchor(id, child: Builder(builder: (context) {
                  final (label, sub) = channel.text(l);
                  final on = allowed && (channels[channel] ?? true);
                  return SettingsTile(
                    icon: icon,
                    label: label,
                    subtitle: sub,
                    disabled: !allowed,
                    onTap: () => openNotificationSettings(channel.id),
                    trailing: _trailing(context, text: on ? l.setOn : l.setOff, icon: Icons.open_in_new_rounded),
                  );
                })),
            ],
          ),
          KuberInfoLine(text: l.setNotifPhoneHint),
          const SizedBox(height: KuberSpace.sectionGap),
          SettingsBlock(
            children: [
              SettingsAnchor('notifInbox', child: SettingsTile(
                icon: Icons.inbox_outlined,
                label: l.setNotifInbox,
                subtitle: l.setNotifInboxSub,
                onTap: () => openNotificationsSheet(context, ref),
                trailing: _trailing(context),
              )),
            ],
          ),
        ],
      ),
    );
  }
}

/// Help: the tutorial and feedback.
class HelpSettingsScreen extends ConsumerWidget {
  final String? highlight;
  const HelpSettingsScreen({super.key, this.highlight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    return SettingsPageFrame(
      title: l.setHelpTitle,
      highlight: highlight,
      children: [
        SettingsBlock(
          children: [
            SettingsAnchor('tutorial', child: SettingsTile(
              icon: Icons.school_rounded,
              label: l.setAppTutorial,
              subtitle: l.setAppTutorialSub,
              onTap: () => launchTutorialFromMore(context, ref),
              trailing: _trailing(context),
            )),
            SettingsAnchor('feedback', child: SettingsTile(
              icon: Icons.rate_review_outlined,
              label: l.setSendFeedback,
              subtitle: l.setSendFeedbackSub,
              onTap: () => context.push('/more/feedback'),
              trailing: _trailing(context),
            )),
          ],
        ),
      ],
    );
  }
}

/// Activity: pages that used to sit in More's App section.
class ActivitySettingsScreen extends StatelessWidget {
  final String? highlight;
  const ActivitySettingsScreen({super.key, this.highlight});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return SettingsPageFrame(
      title: l.setGroupActivity,
      highlight: highlight,
      children: [
        SettingsBlock(
          children: [
            SettingsAnchor('upcoming', child: SettingsTile(
              icon: Icons.calendar_month_rounded,
              label: l.setUpcoming,
              subtitle: l.setUpcomingSub,
              onTap: () => context.push('/more/upcoming-events'),
              trailing: _trailing(context),
            )),
            SettingsAnchor('stories', child: SettingsTile(
              icon: Icons.auto_stories_rounded,
              label: l.setStories,
              subtitle: l.menuStoriesArchiveDesc,
              onTap: () => context.push('/more/stories-archive'),
              trailing: _trailing(context),
            )),
          ],
        ),
      ],
    );
  }
}

/// Home v2 rows in Settings › Widgets: "Get started card" (for 30 days after
/// install) and "Suggestions on Home". Nothing for v1.
class _HomeV2SettingsRows {
  const _HomeV2SettingsRows();

  List<Widget> rows(BuildContext context, WidgetRef ref) {
    final s = ref.watch(homeV2Provider);
    if (!s.isV2) return const [];
    final l = context.l10n;
    final installedAt = s.installedAt;
    // Existing users moved over by the update migration never get Get
    // started (specs/home-v3.3/plan.md §2), so no switch for it either.
    final showGs =
        s.gsGraduationReason != GsGraduation.migrated &&
        (installedAt == null ||
            DateTime.now().difference(installedAt) <= const Duration(days: 30));
    final notifier = ref.read(homeV2Provider.notifier);
    return [
      if (showGs)
        SettingsAnchor('getStarted', child: SettingsTile(
          icon: Icons.flag_outlined,
          label: l.homeV2SetGsTitle,
          subtitle: l.homeV2SetGsSub,
          trailing: Switch(
            value: s.gsEligible,
            onChanged: (on) => notifier.update(
              (x) => on
                  // On: clears graduation; the card returns with current
                  // progress and re-graduates if everything is done.
                  ? x.copyWith(
                      gsSetting: true,
                      gsGraduatedAt: () => null,
                      gsGraduationReason: () => null,
                      gsSuccessShown: false,
                    )
                  // Off counts as dismissed.
                  : x.copyWith(
                      gsSetting: false,
                      gsGraduatedAt: () => x.gsGraduatedAt ?? DateTime.now(),
                      gsGraduationReason: () =>
                          x.gsGraduationReason ?? GsGraduation.dismissed,
                      gsSuccessShown: true,
                    ),
            ),
          ),
        )),
      SettingsAnchor('suggestions', child: SettingsTile(
        icon: Icons.lightbulb_outline_rounded,
        label: l.homeV2SetSgTitle,
        subtitle: l.homeV2SetSgSub,
        trailing: Switch(
          value: s.sgSetting,
          onChanged: (on) => notifier.update((x) => x.copyWith(sgSetting: on)),
        ),
      )),
    ];
  }
}
