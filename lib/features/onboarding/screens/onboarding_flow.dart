import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/database/seed_service.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../settings/providers/settings_provider.dart';
import '../../../core/utils/l10n_ext.dart';
import '../../home_v2/data/tracking_choices.dart';
import '../../why_kuber/why_kuber_screen.dart' show whyKuberTryIt;
import '../../why_kuber/why_kuber_store.dart';
import '../../why_kuber/widgets/why_kuber_page.dart';
import '../pages/onboarding_page_1.dart';
import '../pages/onboarding_page_4.dart';
import '../pages/onboarding_tracking_page.dart';
import '../widgets/onboarding_nav_bar.dart';

/// Welcome flow (specs/home-v3.3/plan.md §5): Welcome (unchanged) → Why
/// Kuber pages 1 to 5 → What do you want to track? → Make it yours → Home.
/// One PageView, 8 dots. Skip on Welcome and every Why Kuber page opens Home
/// (seeding as before); Skip on the tracking question moves on without picks.
///
/// [isReplay] (More › Why Kuber?): Welcome and the 5 Why Kuber pages, with
/// Try it; Skip closes it and page 5 reads Done. Nothing is saved or seeded.
///
/// First run: Skip on Welcome or a Why Kuber page goes to Make it yours (the
/// last page), which every install must pass (name, language, currency,
/// theme, data seeding).
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
  final _tracking = <String>{};
  final _played = <int>{};

  static const _tourFirst = 1;
  static const _trackingPage = _tourFirst + WhyKuberPage.count; // 6
  static const _setupPage = _trackingPage + 1; // 7
  static const _pageCount = _setupPage + 1;
  String _version = '';
  String _selectedCurrencyCode = 'INR';
  ThemeMode _selectedTheme = ThemeMode.system;
  Locale _selectedLocale = const Locale('en');
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final settings = ref.read(settingsProvider).valueOrNull;
    _nameController = TextEditingController(text: settings?.userName ?? '');
    _selectedCurrencyCode = settings?.currency ?? 'INR';
    // Light preselected on first run (user review); a replay never saves.
    _selectedTheme = ThemeMode.light;
    _selectedLocale = settings?.locale ?? const Locale('en');
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
    if (widget.isReplay) {
      if (context.canPop()) context.pop();
      return;
    }
    // The setup page stays required: Skip jumps there (tracking skipped).
    saveTrackingChoices(const {}, skipped: true);
    _pageController.jumpToPage(_setupPage);
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
    await prefs.setBool(PrefsKeys.onboarded, true);
    await SeedService().seedInitialData(ref.read(isarProvider));

    if (!mounted) return;
    // No sheet over Home after onboarding (v3.1 V31-07): day 1 shows only
    // the Get started card. App Tutorial stays in More.
    context.go('/');
  }

  void _onPageChanged(int page) {
    if (!mounted) return;
    setState(() => _currentPage = page);
    if (page == _trackingPage - 1) WhyKuberStore.markSeen(); // reached page 5
  }

  Future<void> _continueTracking() async {
    await applyWelcomeTracking(ref, {..._tracking});
    if (mounted) _goToPage(_setupPage);
  }

  void _skipTracking() {
    saveTrackingChoices(const {}, skipped: true);
    _goToPage(_setupPage);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);
    final l = context.l10n;
    final replay = widget.isReplay;
    final lastReplayPage = _trackingPage - 1;
    final primaryLabel = switch (_currentPage) {
      _ when replay && _currentPage == lastReplayPage => l.homeV33TourDone,
      0 => localizations?.getStarted ?? 'Get started',
      _setupPage =>
        _saving
            ? (localizations?.starting ?? 'Starting...')
            : (localizations?.startJourney ?? 'Start my journey'),
      // Pages 1 to 4 of the tour; page 5 continues to the tracking question.
      < _trackingPage - 1 => l.homeV33TourNext,
      _ => localizations?.continueLabel ?? 'Continue',
    };

    // System back steps back through the flow; it only leaves on Welcome.
    return PopScope(
      canPop: _currentPage == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goToPage(_currentPage - 1);
      },
      child: Scaffold(
        backgroundColor: cs.surface,
        resizeToAvoidBottomInset: false,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  children: [
                    OnboardingPageOne(version: _version, onSkip: _skip),
                    for (var i = 0; i < WhyKuberPage.count; i++)
                      WhyKuberPage(
                        index: i,
                        active: _currentPage == _tourFirst + i,
                        played: _played.contains(i),
                        onPlayed: () => _played.add(i),
                        onSkip: _skip,
                        onTry: replay
                            ? () => whyKuberTryIt(context, ref, i)
                            : null,
                      ),
                    if (!replay)
                      OnboardingTrackingPage(
                        selected: _tracking,
                        onToggle: (key) => setState(
                          () => _tracking.contains(key)
                              ? _tracking.remove(key)
                              : _tracking.add(key),
                        ),
                        onSkip: _skipTracking,
                      ),
                    if (!replay)
                      OnboardingPageFour(
                        formKey: _formKey,
                        nameController: _nameController,
                        selectedCurrencyCode: _selectedCurrencyCode,
                        selectedTheme: _selectedTheme,
                        selectedLocale: _selectedLocale,
                        onCurrencyChanged: (code) {
                          setState(() => _selectedCurrencyCode = code);
                        },
                        onThemeChanged: (mode) {
                          setState(() => _selectedTheme = mode);
                        },
                        onLocaleChanged: (locale) {
                          setState(() => _selectedLocale = locale);
                        },
                        onNameChanged: () => setState(() {}),
                      ),
                  ],
                ),
              ),
              OnboardingNavBar(
                currentPage: _currentPage,
                pageCount: replay ? _trackingPage : _pageCount,
                compactBack: _currentPage == _setupPage,
                showBack: _currentPage != 0,
                busy: _currentPage == _setupPage && _saving,
                primaryEnabled:
                    _currentPage != _trackingPage || _tracking.isNotEmpty,
                onBack: _currentPage == 0
                    ? null
                    : () => _goToPage(_currentPage - 1),
                primaryLabel: primaryLabel,
                onPrimary: switch (_currentPage) {
                  _ when replay && _currentPage == lastReplayPage => _skip,
                  _setupPage => _saveAndStart,
                  _trackingPage => _continueTracking,
                  _ => () => _goToPage(_currentPage + 1),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
