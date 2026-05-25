import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
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
      showKuberSnackBar(context, 'Name updated');
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
        title: 'Theme',
        subtitle: 'Appearance',
        selectedValue: current,
        choices: const [
          SettingsChoice(
            value: ThemeMode.light,
            label: 'Light',
            subtitle: 'Bright surfaces, dark text',
            icon: Icons.light_mode_outlined,
          ),
          SettingsChoice(
            value: ThemeMode.dark,
            label: 'Dark',
            subtitle: 'Black surfaces, light text',
            icon: Icons.dark_mode_outlined,
          ),
          SettingsChoice(
            value: ThemeMode.system,
            label: 'System',
            subtitle: 'Follow your phone setting',
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
        title: 'Bottom Navigation',
        subtitle: 'Appearance',
        selectedValue: current,
        choices: const [
          SettingsChoice(
            value: NavBarStyle.classic,
            label: 'Classic',
            subtitle: 'Standard bar',
            icon: Icons.view_headline_rounded,
          ),
          SettingsChoice(
            value: NavBarStyle.modern,
            label: 'Modern',
            subtitle: 'Floating pill',
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
        title: 'More Tab Layout',
        subtitle: 'Appearance',
        selectedValue: current,
        choices: moreTabLayoutChoices,
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
        title: 'Number Format',
        subtitle: 'Money Display',
        selectedValue: current,
        choices: const [
          SettingsChoice(
            value: NumberSystem.indian,
            label: 'Indian',
            subtitle: '1,23,000.00',
            icon: Icons.language_rounded,
          ),
          SettingsChoice(
            value: NumberSystem.international,
            label: 'International',
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
        title: 'Horizontal Swipe',
        subtitle: 'Transactions',
        selectedValue: current,
        choices: const [
          SettingsChoice(
            value: SwipeMode.changeTabs,
            label: 'Change tabs',
            subtitle:
                'Quickly switch between main app sections by swiping across the screen',
            icon: Icons.swap_horiz_rounded,
          ),
          SettingsChoice(
            value: SwipeMode.performActions,
            label: 'Row actions',
            subtitle:
                'Perform quick actions like edit or delete by swiping on individual history items',
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
            style: GoogleFonts.inter(fontSize: 14, color: cs.onSurfaceVariant),
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
        'Not set';

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
        ? 'Light'
        : currentTheme == ThemeMode.dark
        ? 'Dark'
        : 'System';
    final navStr = currentNavBarStyle == NavBarStyle.classic
        ? 'Classic'
        : 'Modern';
    final moreLayoutStr = currentMoreTabLayout == MoreTabLayout.simple
        ? 'Simple'
        : 'Modern';
    final numberStr = currentNumberSystem == NumberSystem.indian
        ? 'Indian'
        : 'International';
    final swipeStr = currentSwipeMode == SwipeMode.changeTabs
        ? 'Change tabs'
        : 'Row actions';

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
                    'Settings',
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: cs.onSurface,
                      height: 1.15,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Customize how Kuber looks, feels and behaves for you.',
                    style: GoogleFonts.inter(
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
                const _SectionLabel(label: 'PROFILE'),
                const _SectionDescription('How Kuber knows you.'),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Your Name',
                      onTap: () => _showNameBottomSheet(context),
                      trailing: _trailingWidget(
                        context,
                        text: _userNameController.text.isEmpty
                            ? 'Set your name'
                            : _userNameController.text,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // APPEARANCE
                const _SectionLabel(label: 'APPEARANCE'),
                const _SectionDescription('How Kuber looks to you.'),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.palette_outlined,
                      label: 'Theme',
                      subtitle: 'Light, dark, or match your phone',
                      onTap: () => _showThemeSheet(context, currentTheme),
                      trailing: _trailingWidget(context, text: themeStr),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.space_dashboard_rounded,
                      label: 'Bottom Navigation',
                      subtitle: 'Standard bar or floating pill',
                      onTap: () =>
                          _showBottomNavSheet(context, currentNavBarStyle),
                      trailing: _trailingWidget(context, text: navStr),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.grid_view_rounded,
                      label: 'More Tab Layout',
                      subtitle: 'Simple list or Modern hero layout',
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
                const _SectionLabel(label: 'WIDGETS'),
                const _SectionDescription(
                  'Choose what shows on Home and Analytics.',
                ),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.home_outlined,
                      label: 'Home Widgets',
                      subtitle: '$enabledHomeCount enabled · drag to reorder',
                      onTap: () => context.push('/widget-editor/home'),
                      trailing: _trailingWidget(context),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.insert_chart_outlined_rounded,
                      label: 'Analytics Widgets',
                      subtitle:
                          '$enabledAnalyticsCount enabled · drag to reorder',
                      onTap: () => context.push('/widget-editor/analytics'),
                      trailing: _trailingWidget(context),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // MONEY DISPLAY
                const _SectionLabel(label: 'MONEY DISPLAY'),
                const _SectionDescription(
                  'How currency and amounts are shown across the app.',
                ),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Currency',
                      subtitle: 'Symbol and code shown on amounts',
                      onTap: () => _showCurrencyPicker(context, currencyCode),
                      trailing: _trailingWidget(
                        context,
                        text: '${currency.symbol} ${currency.code}',
                      ),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.money_rounded,
                      label: 'Number Format',
                      subtitle: 'Indian (1,23,000) or International (123,000)',
                      onTap: () =>
                          _showNumberFormatSheet(context, currentNumberSystem),
                      trailing: _trailingWidget(context, text: numberStr),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // TRANSACTIONS
                const _SectionLabel(label: 'TRANSACTIONS'),
                const _SectionDescription(
                  'Your defaults when adding new entries.',
                ),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Default Account',
                      subtitle: 'Pre-selected when you Quick Add',
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
                      label: 'Horizontal Swipe',
                      subtitle: 'What swiping left or right does',
                      onTap: () =>
                          _showHorizontalSwipeSheet(context, currentSwipeMode),
                      trailing: _trailingWidget(context, text: swipeStr),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // PRIVACY & SECURITY
                const _SectionLabel(label: 'PRIVACY & SECURITY'),
                const _SectionDescription(
                  'Keep your numbers private and your app locked.',
                ),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.visibility_off_outlined,
                      label: 'Privacy Mode',
                      subtitle: 'Hide all balances and amounts',
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
                      label: 'Biometric Lock',
                      subtitle: 'Unlock with FaceID or Fingerprint',
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
                                'Device authentication is not available or set up',
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
                                'Biometric lock enabled',
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
                              'Biometric lock disabled',
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
                const _SectionLabel(label: 'ABOUT'),
                const _SectionDescription(
                  'Learn about Kuber and the person behind it.',
                ),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      label: 'About Kuber',
                      subtitle:
                          'Vision, origin, and a letter from the developer',
                      onTap: () => context.push('/more/about'),
                      trailing: _trailingWidget(context),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xxl),
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
                  'Default Account',
                  style: GoogleFonts.inter(
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
                      'No accounts found.',
                      style: GoogleFonts.inter(color: cs.onSurfaceVariant),
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
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: cs.onSurface,
                            ),
                          ),
                          subtitle: Text(
                            a.isCreditCard ? 'Credit Card' : 'Bank / Cash',
                            style: GoogleFonts.inter(
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
                              '${a.name} set as default',
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
                          showKuberSnackBar(context, 'Default account cleared');
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
                          'Clear Default',
                          style: GoogleFonts.inter(
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
                      'Your Name',
                      style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(fontSize: 16, color: cs.onSurface),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Please enter your name'
                        : null,
                    decoration: InputDecoration(
                      hintText: 'e.g. Gautam',
                      counterText: '${controller.text.length}/15',
                      counterStyle: GoogleFonts.inter(
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
                      'Done',
                      style: GoogleFonts.inter(
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
        style: GoogleFonts.inter(
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
        style: GoogleFonts.inter(
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
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: cs.onSurface,
                    ),
                  ),
                  if (subtitle case final s?)
                    Text(
                      s,
                      style: GoogleFonts.inter(
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
