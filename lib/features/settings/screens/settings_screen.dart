import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../shared/widgets/kuber_app_bar.dart';

import '../providers/settings_provider.dart';
import '../widgets/settings_widgets.dart';
import '../widgets/currency_selector_sheet.dart';
import '../../../core/utils/formatters.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../../core/services/biometric_service.dart';

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


  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider).valueOrNull;

    // Fallbacks if data isn't ready
    final currentTheme = _tempThemeMode ?? settings?.themeMode ?? ThemeMode.system;
    final currencyCode = _tempCurrencyCode ?? settings?.currency ?? 'INR';
    final currentSwipeMode = _tempSwipeMode ?? settings?.swipeMode ?? SwipeMode.changeTabs;
    final currentNumberSystem = _tempNumberSystem ?? settings?.numberSystem ?? NumberSystem.indian;
    final currentBiometricsEnabled = _tempBiometricsEnabled ?? settings?.biometricsEnabled ?? false;
    final currency = currencyFromCode(currencyCode);

    return Scaffold(
        backgroundColor: cs.surface,
        body: CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: KuberAppBar(showBack: true, title: 'Settings'),
            ),
            // Page header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'App\nSettings',
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
                      'Customize your experience and preferences.',
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
                  // APPEARANCE
                  _SectionLabel(label: 'APPEARANCE'),
                  const SizedBox(height: KuberSpacing.sm),
                  _SettingsCard(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: KuberSpacing.lg,
                          vertical: KuberSpacing.md,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const SquircleIcon(icon: Icons.palette_outlined, size: 18, padding: 8),
                                const SizedBox(width: KuberSpacing.md),
                                Text(
                                  'Theme',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: KuberSpacing.md),
                            SettingsCardSelector<ThemeMode>(
                              options: const [
                                SelectorOption(
                                  value: ThemeMode.light,
                                  label: 'LIGHT',
                                  icon: Icons.light_mode_outlined,
                                ),
                                SelectorOption(
                                  value: ThemeMode.dark,
                                  label: 'DARK',
                                  icon: Icons.dark_mode_outlined,
                                ),
                                SelectorOption(
                                  value: ThemeMode.system,
                                  label: 'SYSTEM',
                                  icon: Icons.settings_brightness_outlined,
                                ),
                              ],
                              selectedValue: currentTheme,
                              onSelected: (val) {
                                setState(() => _tempThemeMode = val);
                                ref.read(settingsProvider.notifier).setThemeMode(val);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                const SizedBox(height: KuberSpacing.xl),

                // PREFERENCE
                _SectionLabel(label: 'PREFERENCE'),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    // Your Name
                    _SettingsTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Your Name',
                      onTap: () => _showNameBottomSheet(context),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _userNameController.text.isEmpty ? 'Set your name' : _userNameController.text,
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: KuberSpacing.sm),
                          Icon(Icons.chevron_right_rounded,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: cs.outline),

                    // Currency
                    _SettingsTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Currency',
                      onTap: () => _showCurrencyPicker(context, currencyCode),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${currency.symbol} ${currency.code}',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(width: KuberSpacing.sm),
                          Icon(Icons.chevron_right_rounded,
                              color: cs.onSurfaceVariant.withValues(alpha: 0.5), size: 20),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: cs.outline),

                    // Number Format
                    Padding(
                      padding: const EdgeInsets.all(KuberSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const SquircleIcon(icon: Icons.money_rounded, size: 18, padding: 8),
                              const SizedBox(width: KuberSpacing.md),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Number Format',
                                    style: GoogleFonts.inter(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                  Text(
                                    'Balances display',
                                    style: GoogleFonts.inter(
                                      fontSize: 11,
                                      color: cs.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              // Text(
                              //   currentNumberSystem == NumberSystem.indian ? 'Indian (₹)' : 'International',
                              //   style: GoogleFonts.inter(
                              //     fontSize: 13,
                              //     fontWeight: FontWeight.w500,
                              //     color: cs.primary,
                              //   ),
                              // ),
                            ],
                          ),
                          const SizedBox(height: KuberSpacing.lg),
                          SettingsCardSelector<NumberSystem>(
                            options: const [
                              SelectorOption(
                                value: NumberSystem.indian,
                                label: 'Indian',
                                subtitle: '1,23,000.00',
                                icon: Icons. language_rounded,
                              ),
                              SelectorOption(
                                value: NumberSystem.international,
                                label: 'International',
                                subtitle: '123,000.00',
                                icon: Icons.public_rounded,
                              ),
                            ],
                            selectedValue: currentNumberSystem,
                            onSelected: (val) {
                              setState(() => _tempNumberSystem = val);
                              ref.read(settingsProvider.notifier).setNumberSystem(val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: KuberSpacing.xl),

                // SWIPE GESTURES
                _SectionLabel(label: 'SWIPE GESTURES'),
                const SizedBox(height: KuberSpacing.sm),
                Column(
                  children: [
                    _SelectableCard(
                      title: 'Horizontal swipe to change tabs',
                      subtitle: 'Quickly switch between main app sections by swiping across the screen.',
                      isSelected: currentSwipeMode == SwipeMode.changeTabs,
                      onTap: () {
                        setState(() => _tempSwipeMode = SwipeMode.changeTabs);
                        ref.read(settingsProvider.notifier).setSwipeMode(SwipeMode.changeTabs);
                      },
                    ),
                    const SizedBox(height: KuberSpacing.sm),
                    _SelectableCard(
                      title: 'Swipe left/right on transactions',
                      subtitle: 'Perform quick actions like edit or delete by swiping on individual history items.',
                      isSelected: currentSwipeMode == SwipeMode.performActions,
                      onTap: () {
                        setState(() => _tempSwipeMode = SwipeMode.performActions);
                        ref.read(settingsProvider.notifier).setSwipeMode(SwipeMode.performActions);
                      },
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // SECURITY & PRIVACY
                _SectionLabel(label: 'SECURITY & PRIVACY'),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.fingerprint_rounded,
                      label: 'Biometric Lock',
                      subtitle: 'FaceID or Fingerprint',
                      trailing: Switch(
                        value: currentBiometricsEnabled,
                        onChanged: (val) async {
                          if (val) {
                            // Only authenticate if turning ON
                            final canAuth = await _biometricService.canAuthenticate();
                            if (!context.mounted) return;

                            if (!canAuth) {
                              showKuberSnackBar(
                                context,
                                'Device authentication is not available or set up',
                                isError: true,
                              );
                              return;
                            }

                            final success = await _biometricService.authenticate();
                            if (!context.mounted) return;

                            if (success) {
                              setState(() => _tempBiometricsEnabled = true);
                              await ref.read(settingsProvider.notifier).setBiometricsEnabled(true);
                              if (!context.mounted) return;
                              showKuberSnackBar(context, 'Biometric lock enabled');
                            }
                          } else {
                            setState(() => _tempBiometricsEnabled = false);
                            await ref.read(settingsProvider.notifier).setBiometricsEnabled(false);
                            if (!context.mounted) return;
                            showKuberSnackBar(context, 'Biometric lock disabled');
                          }
                        },
                        activeTrackColor: cs.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: KuberSpacing.xl),

                // ABOUT
                _SectionLabel(label: 'ABOUT'),
                const SizedBox(height: KuberSpacing.sm),
                _SettingsCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      label: 'App Version',
                      trailing: Consumer(
                        builder: (context, ref, _) {
                          final version = ref.watch(appVersionProvider).valueOrNull ?? '1.1.0';
                          return Text(
                            'v$version',
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: cs.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
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
                      icon: Icon(Icons.close_rounded, color: cs.onSurfaceVariant),
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
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter your name' : null,
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
                        borderSide: BorderSide(color: cs.outline.withValues(alpha: 0.5)),
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
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: cs.onSurfaceVariant,
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
      child: Column(
        children: children,
      ),
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

class _SelectableCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _SelectableCard({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(KuberRadius.md),
      child: Container(
        padding: const EdgeInsets.all(KuberSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected ? cs.primary.withValues(alpha: 0.08) : cs.surfaceContainer,
          borderRadius: BorderRadius.circular(KuberRadius.md),
          border: Border.all(
            color: isSelected ? cs.primary : cs.outline,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? cs.primary : cs.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      color: cs.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: KuberSpacing.md),
              Icon(Icons.check_circle_rounded, color: cs.primary, size: 20),
            ],
          ],
        ),
      ),
    );
  }
}
