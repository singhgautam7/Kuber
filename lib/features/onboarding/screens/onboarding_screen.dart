import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/theme/app_theme.dart';
import '../../settings/providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;
  String _selectedCurrency = 'INR';
  ThemeMode _selectedTheme = ThemeMode.system;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(KuberSpacing.lg),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: const Text('Skip'),
                ),
              ),
            ),
            // Pages
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _WelcomePage(textTheme: textTheme, colorScheme: colorScheme),
                  _SmartEntryPage(
                      textTheme: textTheme, colorScheme: colorScheme),
                  _SetupPage(
                    textTheme: textTheme,
                    colorScheme: colorScheme,
                    selectedCurrency: _selectedCurrency,
                    selectedTheme: _selectedTheme,
                    onCurrencyChanged: (v) =>
                        setState(() => _selectedCurrency = v),
                    onThemeChanged: (v) =>
                        setState(() => _selectedTheme = v),
                  ),
                ],
              ),
            ),
            // Dots + button
            Padding(
              padding: const EdgeInsets.all(KuberSpacing.xl),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page dots
                  Row(
                    children: List.generate(
                      3,
                      (i) => AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: KuberSpacing.sm),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? colorScheme.primary
                              : colorScheme.outlineVariant,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  // Next / Get Started
                  if (_currentPage < 2)
                    FilledButton(
                      onPressed: () => _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutBack,
                      ),
                      child: const Text('Next'),
                    )
                  else
                    FilledButton(
                      onPressed: _finishOnboarding,
                      child: const Text('Get Started'),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishOnboarding() async {
    // Save settings
    final settingsNotifier = ref.read(settingsProvider.notifier);
    await settingsNotifier.setCurrency(_selectedCurrency);
    await settingsNotifier.setThemeMode(_selectedTheme);

    // Seed data
    final isar = ref.read(isarProvider);
    await IsarService.seedIfNeeded(isar);

    // Mark onboarded
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kuber_onboarded', true);

    if (mounted) context.go('/');
  }
}

class _WelcomePage extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _WelcomePage({required this.textTheme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KuberSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.account_balance_wallet,
              size: 80, color: colorScheme.primary),
          const SizedBox(height: KuberSpacing.xl),
          Text('Kuber', style: textTheme.displaySmall),
          const SizedBox(height: KuberSpacing.sm),
          Text(
            'Your money, your way',
            style: textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartEntryPage extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  const _SmartEntryPage({required this.textTheme, required this.colorScheme});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KuberSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.flash_on, size: 80, color: colorScheme.tertiary),
          const SizedBox(height: KuberSpacing.xl),
          Text('Smart Entry', style: textTheme.headlineMedium),
          const SizedBox(height: KuberSpacing.md),
          Text(
            'Type a name, and Kuber auto-fills category, amount, and account from your history.',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SetupPage extends StatelessWidget {
  final TextTheme textTheme;
  final ColorScheme colorScheme;
  final String selectedCurrency;
  final ThemeMode selectedTheme;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<ThemeMode> onThemeChanged;

  const _SetupPage({
    required this.textTheme,
    required this.colorScheme,
    required this.selectedCurrency,
    required this.selectedTheme,
    required this.onCurrencyChanged,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(KuberSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Setup', style: textTheme.headlineMedium),
          const SizedBox(height: KuberSpacing.xxl),
          // Currency
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Currency', style: textTheme.titleMedium),
              const SizedBox(width: KuberSpacing.lg),
              DropdownButton<String>(
                value: selectedCurrency,
                items: ['INR', 'USD', 'EUR', 'GBP']
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) onCurrencyChanged(v);
                },
              ),
            ],
          ),
          const SizedBox(height: KuberSpacing.xl),
          // Theme
          Text('Theme', style: textTheme.titleMedium),
          const SizedBox(height: KuberSpacing.md),
          SegmentedButton<ThemeMode>(
            segments: const [
              ButtonSegment(
                value: ThemeMode.system,
                label: Text('System'),
                icon: Icon(Icons.brightness_auto),
              ),
              ButtonSegment(
                value: ThemeMode.light,
                label: Text('Light'),
                icon: Icon(Icons.light_mode),
              ),
              ButtonSegment(
                value: ThemeMode.dark,
                label: Text('Dark'),
                icon: Icon(Icons.dark_mode),
              ),
            ],
            selected: {selectedTheme},
            onSelectionChanged: (v) => onThemeChanged(v.first),
          ),
        ],
      ),
    );
  }
}
