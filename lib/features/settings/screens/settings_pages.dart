import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:kuber/core/utils/locale_font.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../../core/services/biometric_service.dart';
import '../../../core/services/shortcut_pin_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../core/utils/icon_mapper.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../home_v2/data/home_v2_state.dart';
import '../../home_v2/providers/home_v2_provider.dart';
import '../../kuber_cards/data/card_biometric.dart';
import '../../kuber_cards/providers/kuber_cards_provider.dart';
import '../../more/more_content.dart' show openNotificationsSheet;
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

Widget _trailing(BuildContext context, {String? text}) {
  final cs = Theme.of(context).colorScheme;
  return Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (text != null && text.isNotEmpty) ...[
        Text(
          text,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant),
        ),
        const SizedBox(width: KuberSpace.sm),
      ],
      Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 20),
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
          label: context.l10n.navClassicChoice,
          subtitle: context.l10n.navSubtitleClassic,
          icon: Icons.view_headline_rounded,
        ),
        SettingsChoice(
          value: NavBarStyle.modern,
          label: context.l10n.navModernChoice,
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
          label: context.l10n.numFormatIndian,
          subtitle: '1,23,000.00',
          icon: Icons.language_rounded,
        ),
        SettingsChoice(
          value: NumberSystem.international,
          label: context.l10n.numFormatInternational,
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


void _showHorizontalSwipeSheet(BuildContext context, WidgetRef ref, SwipeMode current) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (_) => SettingsChoiceSheet<SwipeMode>(
      title: context.l10n.horizontalSwipeLabel,
      subtitle: context.l10n.transactionsCategory,
      selectedValue: current,
      choices: [
        SettingsChoice(
          value: SwipeMode.changeTabs,
          label: context.l10n.swipeChangeTabs,
          subtitle: context.l10n.swipeSubtitleChangeTabs,
          icon: Icons.swap_horiz_rounded,
        ),
        SettingsChoice(
          value: SwipeMode.performActions,
          label: context.l10n.swipeRowActions,
          subtitle: context.l10n.swipeSubtitleRowActions,
          icon: Icons.swipe_rounded,
        ),
      ],
      onSelected: (val) {
        ref.read(settingsProvider.notifier).setSwipeMode(val);
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


Widget _divider(ColorScheme cs) => Divider(height: 1, color: cs.outlineVariant);

/// Look and feel: theme, text size, layouts, Home and Analytics widgets.
class LookAndFeelScreen extends ConsumerWidget {
  final String? highlight;
  const LookAndFeelScreen({super.key, this.highlight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final mode = ref.watch(themeModeProvider);
    final variant = ref.watch(themeVariantProvider);
    final nav = ref.watch(settingsProvider.select((s) => s.valueOrNull?.navBarStyle ?? NavBarStyle.modern));
    final layout = ref.watch(moreTabLayoutProvider);
    final themeStr = mode == ThemeMode.light
        ? l.themeLightChoice
        : mode == ThemeMode.dark
        ? l.themeDarkChoice
        : l.themeSystemChoice;
    final homeWidgets = ref.watch(homeWidgetsProvider).valueOrNull ?? <HomeWidgetConfig>[];
    final analyticsWidgets = ref.watch(analyticsWidgetsProvider).valueOrNull ?? <HomeWidgetConfig>[];
    return SettingsPageFrame(
      title: l.setGroupLook,
      highlight: highlight,
      children: [
        SettingsCard(
          children: [
            SettingsAnchor('theme', child: SettingsTile(
              icon: Icons.palette_outlined,
              label: l.themeLabel,
              subtitle: '${themeFamilyName(variant)} • $themeStr',
              onTap: () => context.push('/more/settings/theme'),
              trailing: _trailing(context),
            )),
            _divider(cs),
            SettingsAnchor('textSize', child: SettingsTile(
              icon: Icons.format_size_rounded,
              label: l.textSizeTitle,
              subtitle: l.textSizeDesc,
              onTap: () => TextSizeSheet.show(context),
              trailing: _trailing(context, text: textSizeLabel(context, ref.watch(textSizeLevelProvider))),
            )),
            _divider(cs),
            SettingsAnchor('bottomNav', child: SettingsTile(
              icon: Icons.space_dashboard_outlined,
              label: l.bottomNavLabel,
              subtitle: l.bottomNavSubtitle,
              onTap: () => _showBottomNavSheet(context, ref, nav),
              trailing: _trailing(context, text: nav == NavBarStyle.classic ? l.navClassicChoice : l.navModernChoice),
            )),
            _divider(cs),
            SettingsAnchor('moreLayout', child: SettingsTile(
              icon: Icons.grid_view_outlined,
              label: l.moreTabLayoutLabel,
              subtitle: l.moreTabLayoutSubtitle,
              onTap: () => _showMoreTabLayoutSheet(context, ref, layout),
              trailing: _trailing(context, text: layout == MoreTabLayout.simple ? l.simpleLabel : l.navModernChoice),
            )),
          ],
        ),
        const SizedBox(height: KuberSpace.xl),
        SettingsCard(
          children: [
            SettingsAnchor('homeWidgets', child: SettingsTile(
              icon: Icons.home_outlined,
              label: l.homeWidgetsLabel,
              subtitle: l.homeWidgetsSubtitle('${homeWidgets.where((w) => w.enabled).length}'),
              onTap: () => context.push('/widget-editor/home'),
              trailing: _trailing(context),
            )),
            _divider(cs),
            SettingsAnchor('analyticsWidgets', child: SettingsTile(
              icon: Icons.insert_chart_outlined_rounded,
              label: l.analyticsWidgetsLabel,
              subtitle: l.analyticsWidgetsSubtitle('${analyticsWidgets.where((w) => w.enabled).length}'),
              onTap: () => context.push('/widget-editor/analytics'),
              trailing: _trailing(context),
            )),
            // Home v2 installs only (board HV2.2 Settings).
            ...const _HomeV2SettingsRows().rows(context, ref, cs),
            _divider(cs),
            SettingsAnchor('gallery', child: SettingsTile(
              icon: Icons.widgets_outlined,
              label: l.setHomeScreenWidgets,
              subtitle: l.menuWidgetsDesc,
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
    final numberStr = switch (numberSystem) {
      NumberSystem.indian => l.numFormatIndian,
      NumberSystem.international => l.numFormatInternational,
      NumberSystem.automatic => l.numFormatAutomatic,
    };
    return SettingsPageFrame(
      title: l.setGroupPrefs,
      highlight: highlight,
      children: [
        // English-only literals, like other Kuber-signature surfaces.
        SettingsCard(
          children: [
            SettingsAnchor('quickActions', child: SettingsTile(
              icon: Icons.bolt_outlined,
              label: 'Quick Actions',
              subtitle: 'Nav-bar long-press · controls & shortcuts',
              onTap: () => context.push('/settings/quick-actions'),
              trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            )),
            _divider(cs),
            SettingsAnchor('addMenu', child: SettingsTile(
              icon: Icons.add_circle_outline_rounded,
              label: 'Add Menu',
              subtitle: '+ button long-press · add-entry shortcuts',
              onTap: () => context.push('/settings/add-menu'),
              trailing: Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant),
            )),
          ],
        ),
        const SizedBox(height: KuberSpace.md),
        const _ShortcutsDiscoveryTip(),
        const SizedBox(height: KuberSpace.sm),
        Text(l.setPathTip, style: Theme.of(context).textTheme.bodySmall!.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: KuberSpace.xl),
        SettingsCard(
          children: [
            const SettingsAnchor('language', child: SettingsLanguageRow()),
            _divider(cs),
            SettingsAnchor('currency', child: SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              label: l.currencyLabel,
              subtitle: l.currencySubtitle,
              // Currency selection is free for everyone.
              onTap: () => showCurrencyPicker(context: context, ref: ref, currentCode: currencyCode, onSelected: (_) {}),
              trailing: _trailing(context, text: '${currency.symbol} ${currency.code}'),
            )),
            _divider(cs),
            SettingsAnchor('numberFormat', child: SettingsTile(
              icon: Icons.money_outlined,
              label: l.numberFormatLabel,
              subtitle: l.numberFormatSubtitle,
              onTap: () => _showNumberFormatSheet(context, ref, numberSystem),
              trailing: _trailing(context, text: numberStr),
            )),
            _divider(cs),
            SettingsAnchor('currencyCode', child: SettingsTile(
              icon: Icons.abc_rounded,
              label: l.showCurrencyCode,
              subtitle: l.showCurrencyCodeSub,
              trailing: Switch(
                value: settings?.showCurrencyCode ?? false,
                onChanged: (v) => ref.read(settingsProvider.notifier).setShowCurrencyCode(v),
                activeTrackColor: cs.primary,
              ),
            )),
          ],
        ),
        const SizedBox(height: KuberSpace.xl),
        SettingsCard(
          children: [
            SettingsAnchor('defaultAccount', child: SettingsTile(
              icon: Icons.account_balance_wallet_outlined,
              label: l.defaultAccountLabel,
              subtitle: l.defaultAccountSubtitle,
              onTap: () => _showDefaultAccountPicker(context, ref, accounts, defaultAccId),
              trailing: _trailing(context, text: defaultAccName),
            )),
            _divider(cs),
            SettingsAnchor('swipe', child: SettingsTile(
              icon: Icons.swap_horiz_rounded,
              label: l.horizontalSwipeLabel,
              subtitle: l.horizontalSwipeSubtitle,
              onTap: () => _showHorizontalSwipeSheet(context, ref, swipe),
              trailing: _trailing(context, text: swipe == SwipeMode.changeTabs ? l.swipeChangeTabs : l.swipeRowActions),
            )),
          ],
        ),
      ],
    );
  }
}

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
      if (!await _biometric.authenticate()) return;
      await notifier.setBiometricsEnabled(true);
      if (mounted) showKuberSnackBar(context, l.biometricEnabledMsg);
    } else {
      // Require authentication before disabling biometric lock
      if (!await _biometric.authenticate()) return;
      await notifier.setBiometricsEnabled(false);
      if (mounted) showKuberSnackBar(context, l.biometricDisabledMsg);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final appLock = ref.watch(settingsProvider.select((s) => s.valueOrNull?.biometricsEnabled ?? false));
    final meta = ref.watch(cardVaultMetaProvider).valueOrNull;
    final hasVault = meta != null;
    return SettingsPageFrame(
      title: l.setGroupPrivacy,
      highlight: widget.highlight,
      children: [
        SettingsCard(
          children: [
            SettingsAnchor('privacyMode', child: SettingsTile(
              icon: Icons.visibility_off_outlined,
              label: l.privacyModeLabel,
              subtitle: l.privacyModeSubtitle,
              trailing: Switch(
                value: ref.watch(privacyModeProvider),
                onChanged: (_) => ref.read(settingsProvider.notifier).togglePrivacyMode(),
                activeTrackColor: cs.primary,
              ),
            )),
            _divider(cs),
            SettingsAnchor('biometric', child: SettingsTile(
              icon: Icons.fingerprint_rounded,
              label: l.biometricLockLabel,
              subtitle: l.biometricLockSubtitle,
              trailing: Switch(
                value: appLock,
                onChanged: _setAppLock,
                activeTrackColor: cs.primary,
              ),
            )),
            _divider(cs),
            // Notes-specific gate. Greyed out until the app-wide biometric
            // toggle above is on (per design 1l).
            SettingsAnchor('notesBiometric', child: Opacity(
              opacity: appLock ? 1 : 0.45,
              child: SettingsTile(
                icon: Icons.lock_outline_rounded,
                label: 'Require biometric to open Notes',
                subtitle: appLock
                    ? 'Ask for Face / fingerprint unlock'
                    : 'Turn on Biometric unlock above first',
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
              ),
            )),
            // Shown once a vault exists: there is nothing to protect or
            // change until the user has set up Kuber Cards.
            if (hasVault) ...[
              _divider(cs),
              SettingsAnchor('cardsBiometric', child: SettingsTile(
                icon: Icons.credit_card_outlined,
                label: l.setCardsBiometric,
                subtitle: l.setCardsBiometricSub,
                trailing: Switch(
                  value: meta.biometricEnabled,
                  onChanged: (v) => toggleCardBiometric(context, ref, v,
                      onNeedsUnlock: () => context.push('/cards')),
                  activeTrackColor: cs.primary,
                ),
              )),
              _divider(cs),
              SettingsAnchor('cardsPin', child: SettingsTile(
                icon: Icons.password_rounded,
                label: l.setCardsPin,
                subtitle: l.setCardsPinSub,
                trailing: Icon(Icons.chevron_right_rounded, size: 20, color: cs.onSurfaceVariant),
                // Kuber Cards is free up to 2 cards, so managing the unlock
                // PIN is free too. No entry-level Pro gate.
                onTap: () => context.push('/cards/change-pin'),
              )),
            ],
          ],
        ),
      ],
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
    final cs = Theme.of(context).colorScheme;
    final on = ref.watch(appDrawerEntriesProvider).valueOrNull;
    return SettingsPageFrame(
      title: l.appDrawerSection,
      highlight: highlight,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: KuberSpace.md),
          child: Text(l.appDrawerDescription,
              style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: cs.onSurfaceVariant)),
        ),
        SettingsCard(
          children: [
            for (final (i, e) in [
              (AppDrawerEntry.cards, 'drawerCards', Icons.wallet_rounded, l.appDrawerCards, l.appDrawerCardsSub),
              (AppDrawerEntry.notes, 'drawerNotes', Icons.sticky_note_2_outlined, l.appDrawerNotes, l.appDrawerNotesSub),
              (AppDrawerEntry.reminders, 'drawerReminders', Icons.notifications_none_rounded, l.appDrawerReminders, l.appDrawerRemindersSub),
            ].indexed) ...[
              if (i > 0) _divider(cs),
              SettingsAnchor(e.$2, child: SettingsTile(
                icon: e.$3,
                label: e.$4,
                subtitle: e.$5,
                trailing: Switch(
                  value: on?.contains(e.$1) ?? false,
                  onChanged: (v) => toggleAppDrawerEntry(context, ref, e.$1, v),
                  activeTrackColor: cs.primary,
                ),
              )),
            ],
          ],
        ),
      ],
    );
  }
}

/// Whether the system lets Kuber post notifications. Read on opening the page
/// and when the user comes back from system settings.
final notificationsAllowedProvider = FutureProvider.autoDispose<bool>(
    (ref) async => (await Permission.notification.status).isGranted);

/// Asks the system, or opens system settings once it has been refused.
Future<bool> requestNotifications() async {
  final status = await Permission.notification.request();
  if (status.isPermanentlyDenied) await openAppSettings();
  return status.isGranted;
}

/// Notifications: the current state, a way to turn them on, and the inbox.
class NotificationsSettingsScreen extends ConsumerWidget {
  final String? highlight;
  const NotificationsSettingsScreen({super.key, this.highlight});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final cs = Theme.of(context).colorScheme;
    final allowed = ref.watch(notificationsAllowedProvider).valueOrNull ?? true;
    return SettingsPageFrame(
      title: l.menuNotifications,
      highlight: highlight,
      children: [
        SettingsCard(
          children: [
            SettingsAnchor('notifPermission', child: SettingsTile(
              icon: allowed ? Icons.notifications_active_outlined : Icons.notifications_off_outlined,
              label: allowed ? l.setNotifAllowed : l.setNotifBlocked,
              subtitle: allowed ? l.setNotifAllowedSub : l.setNotifBlockedSub,
              onTap: allowed
                  ? null
                  : () async {
                      await requestNotifications();
                      ref.invalidate(notificationsAllowedProvider);
                    },
              trailing: allowed ? null : _trailing(context),
            )),
            _divider(cs),
            SettingsAnchor('notifInbox', child: SettingsTile(
              icon: Icons.inbox_outlined,
              label: l.setNotifInbox,
              subtitle: l.menuNotificationsDesc,
              onTap: () => openNotificationsSheet(context, ref),
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
    final cs = Theme.of(context).colorScheme;
    return SettingsPageFrame(
      title: l.setGroupActivity,
      highlight: highlight,
      children: [
        SettingsCard(
          children: [
            SettingsAnchor('upcoming', child: SettingsTile(
              icon: Icons.calendar_month_rounded,
              label: 'Upcoming Events',
              subtitle: 'Everything coming up, in one place',
              onTap: () => context.push('/more/upcoming-events'),
              trailing: _trailing(context),
            )),
            _divider(cs),
            SettingsAnchor('stories', child: SettingsTile(
              icon: Icons.auto_stories_rounded,
              label: l.menuStoriesArchive,
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

/// Discovery tip below the SHORTCUTS card — teaches both long-press gestures so
/// the feature is findable without knowing them. Dashed primary-tinted bar.
class _ShortcutsDiscoveryTip extends StatelessWidget {
  const _ShortcutsDiscoveryTip();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(KuberSpace.md),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(KuberShape.largeIncreased),
        border: Border.all(color: cs.primary.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: cs.primary,
              borderRadius: BorderRadius.circular(KuberShape.small),
            ),
            child: Icon(Icons.touch_app_rounded, size: 18, color: cs.onPrimary),
          ),
          const SizedBox(width: KuberSpace.md),
          Expanded(
            child: Text.rich(
              TextSpan(
                style: localeFont(
                  fontSize: 12,
                  color: cs.onSurface,
                  height: 1.45,
                ),
                children: [
                  TextSpan(
                    text: 'Tip: ',
                    style: localeFont(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                  const TextSpan(
                    text:
                        'long-press any bottom-nav tab (Home, History, '
                        'Analytics, More) for Quick Actions, or long-press the '
                        '+ button for the Add menu.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Home v2 rows in Settings › Widgets: "Get started card" (for 30 days after
/// install) and "Suggestions on Home". Nothing for v1.
class _HomeV2SettingsRows {
  const _HomeV2SettingsRows();

  List<Widget> rows(BuildContext context, WidgetRef ref, ColorScheme cs) {
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
      if (showGs) ...[
        Divider(height: 1, color: cs.outlineVariant),
        SettingsAnchor('getStarted', child: SettingsTile(
          icon: Icons.flag_outlined,
          label: l.homeV2SetGsTitle,
          subtitle: l.homeV2SetGsSub,
          onTap: () {},
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
      ],
      Divider(height: 1, color: cs.outlineVariant),
      SettingsAnchor('suggestions', child: SettingsTile(
        icon: Icons.lightbulb_outline_rounded,
        label: l.homeV2SetSgTitle,
        subtitle: l.homeV2SetSgSub,
        onTap: () {},
        trailing: Switch(
          value: s.sgSetting,
          onChanged: (on) => notifier.update((x) => x.copyWith(sgSetting: on)),
        ),
      )),
    ];
  }
}
