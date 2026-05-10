import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/kuber_loader.dart';
import '../../settings/providers/settings_provider.dart';
import '../../tutorial/providers/tutorial_provider.dart';
import '../../tutorial/providers/tutorial_sandbox_provider.dart';
import '../../tutorial/services/tutorial_mock_data_service.dart';
import '../pages/onboarding_page_1.dart';
import '../pages/onboarding_page_2.dart';
import '../pages/onboarding_page_3.dart';
import '../pages/onboarding_page_4.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();
  int _currentPage = 0;
  bool _showTutorial = true;

  // Form state for Page 4 — held here so _submit() can read them
  final _nameController = TextEditingController();
  String _selectedCurrencyCode = 'INR';
  ThemeMode _selectedTheme = ThemeMode.system;

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _advancePage() {
    if (_currentPage < 3) {
      setState(() => _currentPage++);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      setState(() => _currentPage--);
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _skip() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboarded, true);
    if (mounted) context.go('/');
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    final settingsNotifier = ref.read(settingsProvider.notifier);
    await settingsNotifier.setUserName(name);
    await settingsNotifier.setCurrency(_selectedCurrencyCode);
    await settingsNotifier.setThemeMode(_selectedTheme);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(PrefsKeys.onboarded, true);

    if (!mounted) return;

    if (_showTutorial) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => const KuberLoader(label: 'Preparing tutorial...'),
      );
      await TutorialMockDataService()
          .generateMockData(ref.read(tutorialAwareIsarProvider));
      ref.read(tutorialNotifierProvider.notifier).setSandboxMode(false);
      ref.read(tutorialNotifierProvider.notifier).startFromChapter(0);
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
        context.go('/');
      }
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: cs.surface,
      body: PageView(
        controller: _pageController,
        physics: const ClampingScrollPhysics(),
        onPageChanged: (index) => setState(() => _currentPage = index),
        children: [
          OnboardingPage1(
            onGetStarted: _advancePage,
            onSkip: _skip,
          ),
          OnboardingPage2(
            onBack: _prevPage,
            onNext: _advancePage,
            onSkip: _skip,
          ),
          OnboardingPage3(
            onBack: _prevPage,
            onNext: _advancePage,
            onSkip: _skip,
          ),
          OnboardingPage4(
            nameController: _nameController,
            selectedCurrencyCode: _selectedCurrencyCode,
            onCurrencyChanged: (code) =>
                setState(() => _selectedCurrencyCode = code),
            selectedTheme: _selectedTheme,
            onThemeChanged: (mode) => setState(() => _selectedTheme = mode),
            showTutorial: _showTutorial,
            onShowTutorialChanged: (v) => setState(() => _showTutorial = v),
            onBack: _prevPage,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }
}
