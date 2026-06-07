import 'package:kuber/core/utils/locale_font.dart';
import 'package:kuber/core/utils/l10n_ext.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/breakpoints.dart';
import '../../../core/utils/currency_data.dart';
import '../../../shared/widgets/kuber_app_bar.dart';

import '../../accounts/data/account.dart';
import '../../accounts/providers/account_provider.dart';
import '../../../shared/widgets/category_icon.dart';
import '../../../core/utils/icon_mapper.dart';
import '../providers/settings_provider.dart';

import '../widgets/settings_widgets.dart';
import '../widgets/settings_choice_sheet.dart';
import '../widgets/currency_selector_sheet.dart';
import '../widgets/settings_language_row.dart';
import '../../more/widgets/more_tab_layout_picker.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../core/services/biometric_service.dart';

// Imports for widget configurations and count
import '../../widget_editor/providers/widget_editor_provider.dart';
import '../../widget_editor/models/home_widget_config.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _userNameController;
  final _biometricService = BiometricService();
  ThemeMode? _tempThemeMode;
  String? _tempCurrencyCode;
  SwipeMode? _tempSwipeMode;
  NumberSystem? _tempNumberSystem;
  NavBarStyle? _tempNavBarStyle;
  MoreTabLayout? _tempMoreTabLayout;
  bool? _tempBiometricsEnabled;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider).valueOrNull;
    _userNameController = TextEditingController(text: settings?.userName ?? '');
    _tempThemeMode = settings?.themeMode;
    _tempCurrencyCode = settings?.currency;
    _tempSwipeMode = settings?.swipeMode;
    _tempNumberSystem = settings?.numberSystem;
    _tempNavBarStyle = settings?.navBarStyle;
    _tempMoreTabLayout = settings?.moreTabLayout;
    _tempBiometricsEnabled = settings?.biometricsEnabled;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  Future<void> _updateName(String name) async {
    await ref.read(settingsProvider.notifier).setUserName(name);
    if (mounted) {
      showKuberSnackBar(context, context.l10n.userNameUpdated);
    }
  }

  void _showThemeSheet(BuildContext context, ThemeMode current) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (_) => SettingsChoiceSheet<ThemeMode>(
        title: context.l10n.themeLabel,
        subtitle: context.l10n.appearanceCategory,
        selectedValue: current,
        choices: [
          SettingsChoice(
            value: ThemeMode.light,
            label: context.l10n.themeLightChoice,
            subtitle: context.l10n.themeSubtitleLight,
            icon: Icons.light_mode_outlined,
          ),
          SettingsChoice(
            value: ThemeMode.dark,
            label: context.l10n.themeDarkChoice,
            subtitle: context.l10n.themeSubtitleDark,
            icon: Icons.dark_mode_outlined,
          ),
          SettingsChoice(
            value: ThemeMode.system,
            label: context.l10n.themeSystemChoice,
            subtitle: context.l10n.themeSubtitleSystem,
            icon: Icons.settings_brightness_outlined,
          ),
        ],
        onSelected: (val) {
          setState(() => _tempThemeMode = val);
          ref.read(settingsProvider.notifier).setThemeMode(val);
        },
      ),
    );
  }

  void _showBottomNavSheet(BuildContext context, NavBarStyle current) {
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
          setState(() => _tempNavBarStyle = val);
          ref.read(settingsProvider.notifier).setNavBarStyle(val);
        },
      ),
    );
  }

  void _showMoreTabLayoutSheet(BuildContext context, MoreTabLayout current) {
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
          setState(() => _tempMoreTabLayout = val);
          ref.read(settingsProvider.notifier).setMoreTabLayout(val);
        },
      ),
    );
  }

  void _showNumberFormatSheet(BuildContext context, NumberSystem current) {
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
          setState(() => _tempNumberSystem = val);
          ref.read(settingsProvider.notifier).setNumberSystem(val);
        },
      ),
    );
  }

  void _showHorizontalSwipeSheet(BuildContext context, SwipeMode current) {
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
          setState(() => _tempSwipeMode = val);
          ref.read(settingsProvider.notifier).setSwipeMode(val);
        },
      ),
    );
  }

  Widget _trailingWidget(BuildContext context, {String? text}) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (text != null && text.isNotEmpty) ...[
          Text(
            text,
            style: localeFont(fontSize: 14, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: KuberSpacing.sm),
        ],
        Icon(
          Icons.chevron_right_rounded,
          color: cs.onSurfaceVariant.withValues(alpha: 0.5),
          size: 20,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider).valueOrNull;
    final accounts = ref.watch(accountListProvider).valueOrNull ?? <Account>[];
    final defaultAccId = settings?.defaultAccountId;
    final defaultAccName =
        accounts
            .where((a) => a.id.toString() == defaultAccId)
            .firstOrNull
            ?.name ??
        context.l10n.notSet;

    // Fallbacks if data isn't ready
    final currentTheme =
        _tempThemeMode ?? settings?.themeMode ?? ThemeMode.system;
    final currencyCode = _tempCurrencyCode ?? settings?.currency ?? 'INR';
    final currentSwipeMode =
        _tempSwipeMode ?? settings?.swipeMode ?? SwipeMode.changeTabs;
    final currentNumberSystem =
        _tempNumberSystem ?? settings?.numberSystem ?? NumberSystem.indian;
    final currentNavBarStyle =
        _tempNavBarStyle ?? settings?.navBarStyle ?? NavBarStyle.modern;
    final currentMoreTabLayout =
        _tempMoreTabLayout ?? settings?.moreTabLayout ?? MoreTabLayout.simple;
    final currentBiometricsEnabled =
        _tempBiometricsEnabled ?? settings?.biometricsEnabled ?? false;
    final currency = currencyFromCode(currencyCode);

    final themeStr = currentTheme == ThemeMode.light
        ? context.l10n.themeLightChoice
        : currentTheme == ThemeMode.dark
        ? context.l10n.themeDarkChoice
        : context.l10n.themeSystemChoice;
    final navStr = currentNavBarStyle == NavBarStyle.classic
        ? context.l10n.navClassicChoice
        : context.l10n.navModernChoice;
    final moreLayoutStr = currentMoreTabLayout == MoreTabLayout.simple
        ? context.l10n.simpleLabel
        : context.l10n.navModernChoice;
    final numberStr = currentNumberSystem == NumberSystem.indian
        ? context.l10n.numFormatIndian
        : context.l10n.numFormatInternational;
    final swipeStr = currentSwipeMode == SwipeMode.changeTabs
        ? context.l10n.swipeChangeTabs
        : context.l10n.swipeRowActions;

    // Widget configurations and counts
    final homeWidgets =
        ref.watch(homeWidgetsProvider).valueOrNull ?? <HomeWidgetConfig>[];
    final enabledHomeCount = homeWidgets.where((w) => w.enabled).length;

    final analyticsWidgets =
        ref.watch(analyticsWidgetsProvider).valueOrNull ?? <HomeWidgetConfig>[];
    final enabledAnalyticsCount = analyticsWidgets
        .where((w) => w.enabled)
        .length;

    return Scaffold(
      backgroundColor: cs.surface,
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(
            child: KuberAppBar(showBack: true, showHome: true, title: ''),
          ),
          // Page header
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.settingsTitle,
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
                    context.l10n.settingsSubtitle,
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
            padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // PROFILE
                _SectionLabel(label: context.l10n.profileSection),
                _SectionDescription(context.l10n.profileDescription),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      label: context.l10n.yourNameLabel,
                      onTap: () => _showNameBottomSheet(context),
                      trailing: _trailingWidget(
                        context,
                        text: _userNameController.text.isEmpty
                            ? context.l10n.setYourName
                            : _userNameController.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // APPEARANCE
                _SectionLabel(label: context.l10n.appearanceSection),
                _SectionDescription(context.l10n.appearanceDescription),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.palette_outlined,
                      label: context.l10n.themeLabel,
                      subtitle: context.l10n.themeSubtitle,
                      onTap: () => _showThemeSheet(context, currentTheme),
                      trailing: _trailingWidget(context, text: themeStr),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.space_dashboard_rounded,
                      label: context.l10n.bottomNavLabel,
                      subtitle: context.l10n.bottomNavSubtitle,
                      onTap: () =>
                          _showBottomNavSheet(context, currentNavBarStyle),
                      trailing: _trailingWidget(context, text: navStr),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.grid_view_rounded,
                      label: context.l10n.moreTabLayoutLabel,
                      subtitle: context.l10n.moreTabLayoutSubtitle,
                      onTap: () => _showMoreTabLayoutSheet(
                        context,
                        currentMoreTabLayout,
                      ),
                      trailing: _trailingWidget(context, text: moreLayoutStr),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // WIDGETS
                _SectionLabel(label: context.l10n.widgetsSection),
                _SectionDescription(context.l10n.widgetsDescription),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.home_outlined,
                      label: context.l10n.homeWidgetsLabel,
                      subtitle:
                          context.l10n.homeWidgetsSubtitle('$enabledHomeCount'),
                      onTap: () => context.push('/widget-editor/home'),
                      trailing: _trailingWidget(context),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.insert_chart_outlined_rounded,
                      label: context.l10n.analyticsWidgetsLabel,
                      subtitle: context.l10n
                          .analyticsWidgetsSubtitle('$enabledAnalyticsCount'),
                      onTap: () => context.push('/widget-editor/analytics'),
                      trailing: _trailingWidget(context),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // MONEY DISPLAY
                _SectionLabel(label: context.l10n.moneyDisplaySection),
                _SectionDescription(context.l10n.moneyDisplayDescription),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    const SettingsLanguageRow(),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: context.l10n.currencyLabel,
                      subtitle: context.l10n.currencySubtitle,
                      onTap: () => _showCurrencyPicker(context, currencyCode),
                      trailing: _trailingWidget(
                        context,
                        text: '${currency.symbol} ${currency.code}',
                      ),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.money_rounded,
                      label: context.l10n.numberFormatLabel,
                      subtitle: context.l10n.numberFormatSubtitle,
                      onTap: () =>
                          _showNumberFormatSheet(context, currentNumberSystem),
                      trailing: _trailingWidget(context, text: numberStr),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // TRANSACTIONS
                _SectionLabel(label: context.l10n.transactionsSection),
                _SectionDescription(context.l10n.transactionsDescription),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: context.l10n.defaultAccountLabel,
                      subtitle: context.l10n.defaultAccountSubtitle,
                      onTap: () => _showDefaultAccountPicker(
                        context,
                        accounts,
                        defaultAccId,
                      ),
                      trailing: _trailingWidget(context, text: defaultAccName),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.swap_horiz_rounded,
                      label: context.l10n.horizontalSwipeLabel,
                      subtitle: context.l10n.horizontalSwipeSubtitle,
                      onTap: () =>
                          _showHorizontalSwipeSheet(context, currentSwipeMode),
                      trailing: _trailingWidget(context, text: swipeStr),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // PRIVACY & SECURITY
                _SectionLabel(label: context.l10n.privacySecuritySection),
                _SectionDescription(context.l10n.privacySecurityDescription),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.visibility_off_outlined,
                      label: context.l10n.privacyModeLabel,
                      subtitle: context.l10n.privacyModeSubtitle,
                      trailing: Switch(
                        value: ref.watch(privacyModeProvider),
                        onChanged: (_) => ref
                            .read(settingsProvider.notifier)
                            .togglePrivacyMode(),
                        activeTrackColor: cs.primary,
                      ),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.fingerprint_rounded,
                      label: context.l10n.biometricLockLabel,
                      subtitle: context.l10n.biometricLockSubtitle,
                      trailing: Switch(
                        value: currentBiometricsEnabled,
                        onChanged: (val) async {
                          if (val) {
                            // Only authenticate if turning ON
                            final canAuth = await _biometricService
                                .canAuthenticate();
                            if (!context.mounted) return;

                            if (!canAuth) {
                              showKuberSnackBar(
                                context,
                                context.l10n.biometricNotAvailable,
                                isError: true,
                              );
                              return;
                            }

                            final success = await _biometricService
                                .authenticate();
                            if (!context.mounted) return;

                            if (success) {
                              setState(() => _tempBiometricsEnabled = true);
                              await ref
                                  .read(settingsProvider.notifier)
                                  .setBiometricsEnabled(true);
                              if (!context.mounted) return;
                              showKuberSnackBar(
                                context,
                                context.l10n.biometricEnabledMsg,
                              );
                            }
                          } else {
                            // Require authentication before disabling biometric lock
                            final success = await _biometricService
                                .authenticate();
                            if (!context.mounted) return;
                            if (!success) return;

                            setState(() => _tempBiometricsEnabled = false);
                            await ref
                                .read(settingsProvider.notifier)
                                .setBiometricsEnabled(false);
                            if (!context.mounted) return;
                            showKuberSnackBar(
                              context,
                              context.l10n.biometricDisabledMsg,
                            );
                          }
                        },
                        activeTrackColor: cs.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // ABOUT
                _SectionLabel(label: context.l10n.aboutSection),
                _SectionDescription(context.l10n.aboutDescription),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      label: context.l10n.aboutKuberLabel,
                      subtitle: context.l10n.aboutKuberSubtitle,
                      onTap: () => context.push('/more/about'),
                      trailing: _trailingWidget(context),
                    ),
                  ],
                ),
                SizedBox(height: KuberSpacing.xxl + systemNavBarInset(context)),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  void _showDefaultAccountPicker(
    BuildContext context,
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
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        side: BorderSide(color: Theme.of(context).colorScheme.outline),
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
                const SizedBox(height: KuberSpacing.md),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                Text(
                  context.l10n.defaultAccountLabel,
                  style: localeFont(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: cs.onSurface,
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                if (accounts.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(KuberSpacing.xl),
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
                      KuberSpacing.lg,
                      KuberSpacing.sm,
                      KuberSpacing.lg,
                      KuberSpacing.lg,
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
                            borderRadius: BorderRadius.circular(12),
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

  void _showCurrencyPicker(BuildContext context, String currentCode) {
    showCurrencyPicker(
      context: context,
      ref: ref,
      currentCode: currentCode,
      onSelected: (code) => setState(() => _tempCurrencyCode = code),
    );
  }

  void _showNameBottomSheet(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final controller = TextEditingController(text: _userNameController.text);
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Container(
          decoration: BoxDecoration(
            color: cs.surfaceContainer,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: cs.outline),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: KuberSpacing.md),
              Container(
                width: 32,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.onSurfaceVariant.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: KuberSpacing.xl),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Text(
                      context.l10n.yourNameLabel,
                      style: localeFont(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: cs.onSurface,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: Icon(
                        Icons.close_rounded,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KuberSpacing.lg),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controller,
                    autofocus: true,
                    maxLength: 15,
                    textCapitalization: TextCapitalization.words,
                    inputFormatters: [TitleCaseInputFormatter()],
                    onChanged: (_) => setSheetState(() {}),
                    style: localeFont(fontSize: 16, color: cs.onSurface),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? context.l10n.nameRequired
                        : null,
                    decoration: InputDecoration(
                      hintText: context.l10n.nameSheetHint,
                      counterText: '${controller.text.length}/15',
                      counterStyle: localeFont(
                        fontSize: 12,
                        color: cs.onSurfaceVariant,
                      ),
                      filled: true,
                      fillColor: cs.surface,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.outline),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: cs.outline.withValues(alpha: 0.5),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(color: cs.primary, width: 1.5),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.xl),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        final newName = controller.text.trim().toTitleCase();
                        setState(() {
                          _userNameController.text = newName;
                        });
                        _updateName(newName);
                        Navigator.pop(ctx);
                      }
                    },
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      context.l10n.doneLabel,
                      style: localeFont(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(left: KuberSpacing.xs),
      child: Text(
        label,
        style: localeFont(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.8,
          color: cs.primary,
        ),
      ),
    );
  }
}

class _SectionDescription extends StatelessWidget {
  final String text;
  const _SectionDescription(this.text);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        KuberSpacing.xs,
        4,
        KuberSpacing.xs,
        KuberSpacing.sm,
      ),
      child: Text(
        text,
        style: localeFont(
          fontSize: 12.5,
          color: cs.onSurfaceVariant,
          height: 1.4,
          letterSpacing: -0.1,
        ),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(KuberRadius.md),
        border: Border.all(color: cs.outline),
      ),
      child: Column(children: children),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: KuberSpacing.lg,
          vertical: KuberSpacing.md,
        ),
        child: Row(
          children: [
            SquircleIcon(icon: icon, size: 18, padding: 8),
            const SizedBox(width: KuberSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: localeFont(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  if (subtitle case final s?)
                    Text(
                      s,
                      style: localeFont(
                        fontSize: 11,
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: KuberSpacing.sm),
            if (trailing case final Widget t) t,
          ],
        ),
      ),
    );
  }
}