import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../shared/widgets/kuber_app_bar.dart';

import '../providers/settings_provider.dart';


import '../../../shared/widgets/timed_snackbar.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late TextEditingController _userNameController;
  ThemeMode? _tempThemeMode;
  String? _tempCurrencyCode;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider).valueOrNull;
    _userNameController = TextEditingController(text: settings?.userName ?? '');
    _tempThemeMode = settings?.themeMode;
    _tempCurrencyCode = settings?.currency;
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  bool get _hasChanges {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings == null) return false;
    return _userNameController.text.trim() != settings.userName ||
        _tempThemeMode != settings.themeMode ||
        _tempCurrencyCode != settings.currency;
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.setUserName(_userNameController.text.trim());
    if (_tempThemeMode != null) await notifier.setThemeMode(_tempThemeMode!);
    if (_tempCurrencyCode != null) await notifier.setCurrency(_tempCurrencyCode!);

    if (mounted) {
      showKuberSnackBar(context, 'Settings saved successfully');
      setState(() => _isSaving = false);
    }
  }

  void _revertTheme() {
    final settings = ref.read(settingsProvider).valueOrNull;
    if (settings != null) {
      ref.read(themeModeProvider.notifier).state = settings.themeMode;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final settings = ref.watch(settingsProvider).valueOrNull;

    // Fallbacks if data isn't ready
    final currentTheme = _tempThemeMode ?? settings?.themeMode ?? ThemeMode.system;
    final currencyCode = _tempCurrencyCode ?? settings?.currency ?? 'INR';
    final currency = currencyFromCode(currencyCode);

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && !_isSaving) {
          _revertTheme();
        }
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        appBar: const KuberAppBar(showBack: true, title: 'Settings'),
        body: CustomScrollView(
          slivers: [
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
                                Icon(Icons.palette_outlined, size: 20, color: cs.onSurface),
                                const SizedBox(width: KuberSpacing.md),
                                Text(
                                  'Theme',
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                    color: cs.onSurface,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: KuberSpacing.md),
                            SizedBox(
                              width: double.infinity,
                              child: SegmentedButton<ThemeMode>(
                                segments: const [
                                  ButtonSegment(
                                    value: ThemeMode.light,
                                    label: Text('Light'),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.dark,
                                    label: Text('Dark'),
                                  ),
                                  ButtonSegment(
                                    value: ThemeMode.system,
                                    label: Text('System'),
                                  ),
                                ],
                                selected: {currentTheme},
                                onSelectionChanged: (val) {
                                  setState(() => _tempThemeMode = val.first);
                                  // Immediate preview
                                  ref.read(themeModeProvider.notifier).state = val.first;
                                },
                              ),
                            ),
                            if (_tempThemeMode != settings?.themeMode) ...[
                              const SizedBox(height: KuberSpacing.sm),
                              Text(
                                'Save the settings to apply this theme',
                                style: GoogleFonts.inter(
                                  fontSize: 12,
                                  color: cs.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
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
                    // User Name
                    Padding(
                      padding: const EdgeInsets.all(KuberSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.person_outline_rounded, size: 20, color: cs.onSurface),
                              const SizedBox(width: KuberSpacing.md),
                              Text(
                                'Your Name',
                                style: GoogleFonts.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: cs.onSurface,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: KuberSpacing.md),
                          TextField(
                            controller: _userNameController,
                            maxLength: 15,
                            onChanged: (_) => setState(() {}),
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: cs.onSurface,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your name',
                              hintStyle: GoogleFonts.inter(
                                fontSize: 14,
                                color: cs.onSurfaceVariant.withValues(alpha: 0.5),
                              ),
                              filled: true,
                              fillColor: cs.surfaceContainerHigh,
                              counterText: '', // Hide default counter
                              suffixText: '${_userNameController.text.length}/15',
                              suffixStyle: GoogleFonts.inter(
                                fontSize: 11,
                                color: cs.onSurfaceVariant,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(KuberRadius.md),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: KuberSpacing.lg,
                                vertical: KuberSpacing.md,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(height: 1, color: cs.outline),
                    _SettingsTile(
                      icon: Icons.attach_money_rounded,
                      label: 'Currency',
                      trailing: GestureDetector(
                        onTap: () => _showCurrencyPicker(context, currencyCode),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${currency.symbol}  ${currency.code}',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: KuberSpacing.xs),
                            Icon(Icons.chevron_right_rounded,
                                color: cs.onSurfaceVariant, size: 20),
                          ],
                        ),
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
                      trailing: Text(
                        'v1.0.0',
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: cs.onSurfaceVariant,
                        ),
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
      bottomNavigationBar: _hasChanges
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(KuberSpacing.lg),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: _saveSettings,
                    style: FilledButton.styleFrom(
                      backgroundColor: cs.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                    ),
                    child: Text(
                      'Save Settings',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context, String currentCode) {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: cs.surfaceContainer,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(28),
        ),
        side: BorderSide(color: cs.outline),
      ),
      builder: (ctx) {
        final sheetCs = Theme.of(ctx).colorScheme;
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx, scrollController) {
            return Column(
              children: [
                const SizedBox(height: KuberSpacing.md),
                Container(
                  width: 32,
                  height: 4,
                  decoration: BoxDecoration(
                    color: sheetCs.onSurfaceVariant.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                Text(
                  'Select Currency',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: sheetCs.onSurface,
                  ),
                ),
                const SizedBox(height: KuberSpacing.lg),
                Expanded(
                  child: ListView.builder(
                    controller: scrollController,
                    itemCount: kCurrencies.length,
                    itemBuilder: (ctx, i) {
                      final c = kCurrencies[i];
                      final isSelected = c.code == currentCode;
                      return ListTile(
                        leading: Container(
                          width: 40,
                          height: 40,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? sheetCs.primaryContainer
                                : sheetCs.surfaceContainerHigh,
                            borderRadius:
                                BorderRadius.circular(KuberRadius.md),
                          ),
                          child: Text(
                            c.symbol,
                            style: GoogleFonts.inter(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isSelected
                                  ? sheetCs.primary
                                  : sheetCs.onSurfaceVariant,
                            ),
                          ),
                        ),
                        title: Text(
                          c.name,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: sheetCs.onSurface,
                          ),
                        ),
                        subtitle: Text(
                          c.code,
                          style: GoogleFonts.inter(
                            fontSize: 12,
                            color: sheetCs.onSurfaceVariant,
                          ),
                        ),
                        trailing: isSelected
                            ? Icon(Icons.check_rounded,
                                color: sheetCs.primary, size: 20)
                            : null,
                        onTap: () {
                          setState(() => _tempCurrencyCode = c.code);
                          Navigator.pop(ctx);
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
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
  final Widget? trailing;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = cs.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: KuberSpacing.lg,
        vertical: KuberSpacing.md,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: KuberSpacing.md),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
          const SizedBox(width: KuberSpacing.sm),
          if (trailing != null) Flexible(child: trailing!),
        ],
      ),
    );
  }
}
