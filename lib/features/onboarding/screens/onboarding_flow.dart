import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/formatters.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../settings/providers/settings_provider.dart';
import '../pages/onboarding_page_1.dart';
import '../pages/onboarding_page_2.dart';
import '../pages/onboarding_page_3.dart';
import '../pages/onboarding_page_4.dart';
import '../widgets/onboarding_nav_bar.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  final bool isReplay;

  const OnboardingFlow({super.key, this.isReplay = false});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;

  int _currentPage = 0;
  String _version = '';
  String _selectedCurrencyCode = 'INR';
  ThemeMode _selectedTheme = ThemeMode.system;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider).valueOrNull;
    _nameController = TextEditingController(text: settings?.userName ?? '');
    _selectedCurrencyCode = settings?.currency ?? 'INR';
    _selectedTheme = settings?.themeMode ?? ref.read(themeModeProvider);
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = 'v${info.version}');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _skip() async {
    if (widget.isReplay && context.canPop()) {
      context.pop();
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboarded, true);
    if (mounted) context.go('/');
  }

  Future<void> _saveAndStart() async {
    if (_saving) return;
    final valid = _formKey.currentState?.validate() ?? false;
    if (!valid) return;

    setState(() => _saving = true);
    final notifier = ref.read(settingsProvider.notifier);
    final name = _nameController.text.trim().toTitleCase();
    await notifier.setUserName(name);
    await notifier.setCurrency(_selectedCurrencyCode);
    await notifier.setThemeMode(_selectedTheme);

    final prefs = await SharedPreferences.getInstance();
    final wasOnboarded = prefs.getBool(PrefsKeys.onboarded) ?? false;
    await prefs.setBool(PrefsKeys.onboarded, true);
    if (!wasOnboarded && !widget.isReplay) {
      await prefs.setBool(PrefsKeys.onboardingTutorialNudgePending, true);
    }

    if (!mounted) return;
    context.go('/');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final primaryLabel = switch (_currentPage) {
      0 => 'Get started',
      3 => _saving ? 'Starting...' : 'Start my journey',
      _ => 'Continue',
    };

    return Scaffold(
      backgroundColor: cs.surface,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  OnboardingPageOne(version: _version, onSkip: _skip),
                  OnboardingPageTwo(onSkip: _skip),
                  OnboardingPageThree(onSkip: _skip),
                  OnboardingPageFour(
                    formKey: _formKey,
                    nameController: _nameController,
                    selectedCurrencyCode: _selectedCurrencyCode,
                    selectedTheme: _selectedTheme,
                    onCurrencyChanged: (code) {
                      setState(() => _selectedCurrencyCode = code);
                    },
                    onThemeChanged: (mode) {
                      setState(() => _selectedTheme = mode);
                    },
                    onNameChanged: () => setState(() {}),
                  ),
                ],
              ),
            ),
            OnboardingNavBar(
              currentPage: _currentPage,
              showBack: _currentPage != 0,
              onBack: _currentPage == 0
                  ? null
                  : () => _goToPage(_currentPage - 1),
              primaryLabel: primaryLabel,
              onPrimary: _currentPage == 3
                  ? _saveAndStart
                  : () => _goToPage(_currentPage + 1),
            ),
          ],
        ),
      ),
    );
  }
}
