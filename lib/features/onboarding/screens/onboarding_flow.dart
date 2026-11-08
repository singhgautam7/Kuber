import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/database/isar_service.dart';
import '../../../core/database/seed_service.dart';
import '../../../core/services/data_service.dart' show ImportCancelled;
import '../../../core/utils/formatters.dart';
import '../../../core/utils/prefs_keys.dart';
import '../../../shared/widgets/timed_snackbar.dart';
import '../../kuber_cards/widgets/imported_cards_prompt.dart';
import '../../settings/providers/data_provider.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/screens/settings_pages.dart' show requestNotifications;
import '../../../core/utils/l10n_ext.dart';
import '../../why_kuber/why_kuber_screen.dart' show whyKuberTryIt;
import '../../why_kuber/why_kuber_store.dart';
import '../../why_kuber/widgets/why_kuber_page.dart';
import '../pages/onboarding_data_terms_page.dart';
import '../pages/onboarding_notifications_page.dart';
import '../pages/onboarding_page_1.dart';
import '../pages/onboarding_page_4.dart';
import '../pages/onboarding_start_page.dart';
import '../widgets/onboarding_entrance.dart';
import '../widgets/onboarding_nav_bar.dart';

/// Welcome flow (specs/home-v3.3/plan.md §5, nov-release Part B): first page
/// (language, restore, CSV, Start fresh) → Welcome → Why Kuber pages 1 to 5 →
/// Make it yours → Notifications → Data responsibility → Home. One PageView.
/// `onboarded` is set only on the last page.
///
/// [isReplay] (More › Why Kuber?): only Welcome and the 5 Why Kuber pages,
/// with Try it; Skip closes it and page 5 reads Done. Nothing is saved or
/// seeded.
///
/// First run: Skip on Welcome or a Why Kuber page goes to Make it yours (the
/// last page), which every install must pass (name, language, currency,
/// theme, data seeding).
/// Version of the data responsibility wording, saved with the acceptance.
/// Bump it when the wording changes to be able to show the page again.
const kDataTermsVersion = 1;

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
  final _played = <int>{};

  // Page indexes: a replay has no first page or the setup pages.
  late final int _welcomePage = widget.isReplay ? 0 : 1;
  late final int _tourFirst = _welcomePage + 1;
  late final int _setupPage = _tourFirst + WhyKuberPage.count;
  late final int _notificationsPage = _setupPage + 1;
  late final int _termsPage = _notificationsPage + 1;
  late final int _pageCount = _termsPage + 1;

  /// Restored from a backup: the details steps are done.
  bool _restored = false;
  bool _termsBackups = false, _termsResponsibility = false;
  String _version = '';
  String _selectedCurrencyCode = 'INR';
  ThemeMode _selectedTheme = ThemeMode.system;
  Locale _selectedLocale = const Locale('en');
  bool _saving = false;

  /// The first page's restore or import, running or failed.
  StartJob? _job;
  StartJob? _failed;
  String _fileName = '';

  /// Whether Android asks for the notification permission at all.
  bool _notifPrompt = true;

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
    _loadPermissionKind();
  }

  Future<void> _loadVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) setState(() => _version = 'v${info.version}');
  }

  /// Android 12 and older has no notification prompt: the page only explains.
  Future<void> _loadPermissionKind() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) return;
    final info = await DeviceInfoPlugin().androidInfo;
    if (mounted) setState(() => _notifPrompt = info.version.sdkInt >= 33);
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
    // The setup page stays required: Skip jumps there.
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
    await SeedService().seedInitialData(ref.read(isarProvider));
    if (!mounted) return;
    setState(() => _saving = false);
    _goToPage(_notificationsPage);
  }

  /// Picks a file and runs the existing import. True when it finished. The
  /// card shows the run; a failure stays on it with its ways on.
  Future<bool> _import(StartJob job, String ext,
      {required bool json, required String cancelled, ValueChanged<String>? onRead}) async {
    final messenger = context;
    final picked = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: [ext],
    );
    if (!messenger.mounted) return false;
    if (picked?.path == null) {
      showKuberSnackBar(messenger, cancelled);
      return false;
    }
    setState(() {
      _job = job;
      _failed = null;
      _fileName = picked!.path!.split('/').last;
    });
    final data = ref.read(dataControllerProvider.notifier);
    var ok = false;
    var locked = false;
    String? message;
    var wasCancelled = false;
    try {
      final content = await File(picked!.path!).readAsString();
      onRead?.call(content);
      await data.runImport(content, isJson: json);
      final state = ref.read(dataControllerProvider);
      ok = state.status == DataOpStatus.success;
      locked = state.lockedCardsFound;
      message = state.message;
      wasCancelled = message?.contains(ImportCancelled.message) ?? false;
    } on FileSystemException {
      ok = false;
    }
    if (!mounted) return false;
    data.reset();
    setState(() {
      _job = null;
      _failed = ok || wasCancelled ? null : job;
    });
    if (wasCancelled) {
      showKuberSnackBar(context, cancelled);
      return false;
    }
    if (ok && message != null) showKuberSnackBar(context, message);
    // A restore with encrypted cards asks for the backup's PIN, as in Data.
    if (ok && locked) showImportedCardsPrompt(context);
    return ok;
  }

  /// Restore: a backup with a name and currency fills the details, so straight
  /// to Notifications. An older backup has neither: Make it yours asks.
  Future<void> _restore() async {
    String? content;
    final ok = await _import(StartJob.restore, 'json', json: true,
        cancelled: context.l10n.obRestoreCancelled, onRead: (c) => content = c);
    if (!ok || !mounted) return;
    final data = await compute(jsonDecode, content!) as Map<String, dynamic>;
    if (!mounted) return;
    final profile = data['profile'] as Map<String, dynamic>?;
    final name = profile?['userName'] as String?;
    final currency = profile?['currency'] as String?;
    if (name == null || name.isEmpty || currency == null) {
      _pageController.jumpToPage(_setupPage);
      return;
    }
    final notifier = ref.read(settingsProvider.notifier);
    await notifier.setUserName(name);
    await notifier.setCurrency(currency);
    await notifier.setThemeMode(_selectedTheme);
    if (!mounted) return;
    setState(() => _restored = true);
    _pageController.jumpToPage(_notificationsPage);
  }

  /// CSV: the importer makes accounts and categories itself, but a CSV has no
  /// name or currency, so Make it yours asks for those (decisions.md D9).
  Future<void> _importCsv() async {
    final ok = await _import(StartJob.csv, 'csv', json: false, cancelled: context.l10n.obImportCancelled);
    if (!ok || !mounted) return;
    _pageController.jumpToPage(_setupPage);
  }

  Future<void> _allowNotifications() async {
    if (_notifPrompt) await requestNotifications();
    if (mounted) _goToPage(_termsPage);
  }

  /// The end of the flow: `onboarded` is written here, so leaving earlier
  /// comes back to the first page.
  Future<void> _acceptTerms() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(PrefsKeys.dataTermsAcceptedAt, DateTime.now().toIso8601String());
    await prefs.setInt(PrefsKeys.dataTermsVersion, kDataTermsVersion);
    await prefs.setBool(PrefsKeys.onboarded, true);
    if (!mounted) return;
    // No sheet over Home after onboarding (v3.1 V31-07): day 1 shows only
    // the Get started card. App Tutorial stays in More.
    context.go('/');
  }

  /// Start fresh rises with the first page's cards; a replay has no first page.
  Widget _startEntrance(Widget bar) => widget.isReplay
      ? bar
      : OnboardingEntrance(
          delay: const Duration(milliseconds: 230),
          duration: const Duration(milliseconds: 250),
          beginOffset: Offset.zero,
          rise: 16,
          child: bar,
        );

  void _onPageChanged(int page) {
    if (!mounted) return;
    setState(() => _currentPage = page);
    if (page == _setupPage - 1) WhyKuberStore.markSeen(); // reached page 5
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final localizations = AppLocalizations.of(context);
    final l = context.l10n;
    final replay = widget.isReplay;
    final page = _currentPage;
    final lastReplayPage = _setupPage - 1;
    final isStart = !replay && page == 0;
    final String primaryLabel;
    if (replay && page == lastReplayPage) {
      primaryLabel = l.homeV33TourDone;
    } else if (isStart) {
      primaryLabel = l.obStartFresh;
    } else if (page == _welcomePage) {
      primaryLabel = localizations?.getStarted ?? 'Get started';
    } else if (page == _setupPage) {
      primaryLabel = l.homeV33TourNext;
    } else if (page == _notificationsPage) {
      primaryLabel = _notifPrompt ? l.obNotifAllowShort : l.continueLabel;
    } else if (page == _termsPage) {
      primaryLabel = l.obTermsAgree;
    } else if (page < _setupPage - 1) {
      // Pages 1 to 4 of the tour; page 5 continues to Make it yours.
      primaryLabel = l.homeV33TourNext;
    } else {
      primaryLabel = localizations?.continueLabel ?? 'Continue';
    }
    final termsOk = _termsBackups && _termsResponsibility;
    // After a restore the pages before Notifications are done with.
    final firstPage = _restored ? _notificationsPage : 0;
    void back() => _goToPage(page == _notificationsPage && !_restored ? _setupPage : page - 1);
    final VoidCallback onPrimary;
    if (replay && page == lastReplayPage) {
      onPrimary = _skip;
    } else if (page == _setupPage) {
      onPrimary = _saveAndStart;
    } else if (page == _notificationsPage) {
      onPrimary = _allowNotifications;
    } else if (page == _termsPage) {
      onPrimary = _acceptTerms;
    } else {
      onPrimary = () => _goToPage(page + 1);
    }

    // System back steps back through the flow; it only leaves on Welcome.
    return PopScope(
      canPop: page == firstPage,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) back();
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
                  // Pages that must be finished with their own button.
                  physics: isStart || (!replay && page >= _setupPage)
                      ? const NeverScrollableScrollPhysics()
                      : const BouncingScrollPhysics(),
                  onPageChanged: _onPageChanged,
                  children: [
                    if (!replay)
                      OnboardingStartPage(
                        job: _job,
                        failed: _failed,
                        fileName: _fileName,
                        onRestore: _restore,
                        onImportCsv: _importCsv,
                        onCancelImport: ref.read(dataControllerProvider.notifier).cancelImport,
                        onLocaleChanged: (locale) => setState(() => _selectedLocale = locale),
                      ),
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
                    if (!replay) const OnboardingNotificationsPage(),
                    if (!replay)
                      OnboardingDataTermsPage(
                        backups: _termsBackups,
                        responsibility: _termsResponsibility,
                        onBackups: (v) => setState(() => _termsBackups = v),
                        onResponsibility: (v) => setState(() => _termsResponsibility = v),
                      ),
                  ],
                ),
              ),
              _startEntrance(
                OnboardingNavBar(
                  currentPage: page - _welcomePage,
                  pageCount: replay ? _setupPage : _pageCount - _welcomePage,
                  showDots: !isStart,
                  compactBack: page == _setupPage || page >= _notificationsPage,
                  showBack: page != 0 && page != firstPage && page != _notificationsPage,
                  busy: page == _setupPage && _saving,
                  primaryEnabled: (page != _termsPage || termsOk) &&
                      (!isStart || _job == null),
                  onBack: page == firstPage ? null : back,
                  primaryLabel: primaryLabel,
                  onPrimary: onPrimary,
                  showArrow: page != _notificationsPage && (page != _termsPage || termsOk),
                  secondaryLabel: page == _notificationsPage && _notifPrompt ? l.obNotifLater : null,
                  caption: page == _notificationsPage && _notifPrompt ? l.obNotifAllow : null,
                  onSecondary: () => _goToPage(_termsPage),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
