import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/currency_data.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../settings/providers/settings_provider.dart';

class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final _nameController = TextEditingController();
  String _selectedCurrencyCode = 'INR';
  ThemeMode _selectedTheme = ThemeMode.dark;

  bool get _canContinue => _nameController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveAndStart() async {
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.setUserName(_nameController.text.trim());
    await notifier.setCurrency(_selectedCurrencyCode);
    await notifier.setThemeMode(_selectedTheme);

    final isar = ref.read(isarProvider);
    await IsarService.seedIfNeeded(isar);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboarded, true);

    if (mounted) context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: KuberColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: KuberSpacing.xl),
          child: Column(
            children: [
              const SizedBox(height: KuberSpacing.xxl),

              // App icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: KuberColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: KuberColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(height: KuberSpacing.xl),

              // Headline
              Text(
                'Set Up Your Profile',
                style: GoogleFonts.inter(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: KuberColors.textPrimary,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KuberSpacing.sm),
              Text(
                'Personalize Kuber before you start.',
                style: GoogleFonts.inter(
                  fontSize: 14,
                  color: KuberColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KuberSpacing.xxl),

              // Form card
              Container(
                padding: const EdgeInsets.all(KuberSpacing.xl),
                decoration: BoxDecoration(
                  color: KuberColors.surfaceCard,
                  borderRadius: BorderRadius.circular(KuberRadius.md),
                  border: Border.all(color: KuberColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    const _FormLabel('Your Name'),
                    const SizedBox(height: KuberSpacing.sm),
                    TextField(
                      controller: _nameController,
                      onChanged: (_) => setState(() {}),
                      style: GoogleFonts.inter(color: KuberColors.textPrimary),
                      decoration: InputDecoration(
                        hintText: 'Enter your name',
                        hintStyle: GoogleFonts.inter(
                          color: KuberColors.textSecondary,
                        ),
                        filled: true,
                        fillColor: KuberColors.surfaceMuted,
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
                    const SizedBox(height: KuberSpacing.xl),

                    // Currency dropdown
                    const _FormLabel('Currency'),
                    const SizedBox(height: KuberSpacing.sm),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: KuberSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        color: KuberColors.surfaceMuted,
                        borderRadius: BorderRadius.circular(KuberRadius.md),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedCurrencyCode,
                          dropdownColor: KuberColors.surfaceCard,
                          isExpanded: true,
                          style: GoogleFonts.inter(
                            fontSize: 14,
                            color: KuberColors.textPrimary,
                          ),
                          items: kCurrencies.map((c) {
                            return DropdownMenuItem(
                              value: c.code,
                              child: Text('${c.symbol}  ${c.code} — ${c.name}'),
                            );
                          }).toList(),
                          onChanged: (v) {
                            if (v != null) setState(() => _selectedCurrencyCode = v);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: KuberSpacing.xl),

                    // Theme selector
                    const _FormLabel('Theme'),
                    const SizedBox(height: KuberSpacing.sm),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<ThemeMode>(
                        segments: const [
                          ButtonSegment(
                            value: ThemeMode.system,
                            label: Text('System'),
                            icon: Icon(Icons.brightness_auto, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.light,
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode, size: 18),
                          ),
                          ButtonSegment(
                            value: ThemeMode.dark,
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode, size: 18),
                          ),
                        ],
                        selected: {_selectedTheme},
                        onSelectionChanged: (v) {
                          setState(() => _selectedTheme = v.first);
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: KuberSpacing.xxl),

              // Start button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _canContinue ? _saveAndStart : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: KuberColors.primary,
                    disabledBackgroundColor:
                        KuberColors.primary.withValues(alpha: 0.3),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(KuberRadius.md),
                    ),
                  ),
                  child: Text(
                    'Start My Journey',
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _canContinue
                          ? Colors.white
                          : Colors.white.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: KuberSpacing.xxl),

              // Stat tiles
              Row(
                children: const [
                  Expanded(
                    child: _StatTile(
                      icon: Icons.shield_outlined,
                      label: '100% Private',
                    ),
                  ),
                  SizedBox(width: KuberSpacing.md),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.smartphone_outlined,
                      label: 'Local-First',
                    ),
                  ),
                  SizedBox(width: KuberSpacing.md),
                  Expanded(
                    child: _StatTile(
                      icon: Icons.auto_graph_rounded,
                      label: 'Smart Insights',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: KuberSpacing.xl),

              // Footer
              Text(
                'Your data never leaves your device.',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: KuberColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: KuberSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String text;
  const _FormLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: KuberColors.textSecondary,
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;

  const _StatTile({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: KuberSpacing.md,
        horizontal: KuberSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: KuberColors.surfaceMuted,
        borderRadius: BorderRadius.circular(KuberRadius.md),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: KuberColors.primary),
          const SizedBox(height: KuberSpacing.xs),
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: KuberColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
