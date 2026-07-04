import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/analytics/screens/analytics_filter_screen.dart';

import '../../features/history/screens/advanced_filter_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/tutorial/screens/tutorial_chapter_screen.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/transactions/screens/transaction_list_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../shared/widgets/screen_entrance.dart';
import '../../features/accounts/data/account.dart';
import '../../features/accounts/screens/accounts_screen.dart';
import '../../features/accounts/screens/add_edit_account_screen.dart';
import '../../features/accounts/screens/edit_account_screen.dart';
import '../../features/more/screens/more_screen.dart';
import '../../features/more/screens/more_search_screen.dart';
import '../../features/more/screens/about_screen.dart';
import '../../features/more/screens/feedback_screen.dart';
import '../../features/more/screens/permissions_screen.dart';
import '../../features/more/screens/categories_screen.dart';
import '../../features/more/screens/tags_screen.dart';
import '../../features/more/screens/how_to_use_screen.dart';
import '../../features/categories/data/category.dart';
import '../../features/more/screens/add_edit_category_screen.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/recurring/screens/add_recurring_screen.dart';
import '../../features/recurring/screens/recurring_loader_screen.dart';
import '../../features/recurring/screens/recurring_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../../features/settings/screens/data_management_screen.dart';
import '../../features/backups/screens/automatic_backups_screen.dart';
import '../../features/stories/screens/story_archive_screen.dart';
import '../../features/ledger/data/ledger.dart';
import '../../features/ledger/data/ledger_prefill.dart';
import '../../features/ledger/screens/ledger_screen.dart';
import '../../features/ledger/screens/add_ledger_screen.dart';
import '../../features/loans/data/loan.dart';
import '../../features/loans/screens/loans_screen.dart';
import '../../features/loans/screens/add_loan_screen.dart';
import '../../features/investments/data/investment.dart';
import '../../features/investments/screens/investments_screen.dart';
import '../../features/investments/screens/add_investment_screen.dart';
import '../../features/more/screens/charts_screen.dart';
import '../../features/sms_import/screens/sms_import_screen.dart';
import '../../features/ask_kuber/screen/ask_kuber_screen.dart';
import '../../features/more/screens/troubleshoot_screen.dart';
import '../../features/budgets/data/budget.dart';
import '../../features/dev/screens/dev_tools_screen.dart';
import '../../features/dev/screens/db_explorer_screen.dart';
import '../../features/dev/screens/db_collection_screen.dart';
import '../../features/budgets/screens/budgets_screen.dart';
import '../../features/budgets/screens/add_edit_budget_screen.dart';
import '../../features/widget_editor/models/home_widget_config.dart';
import '../../features/widget_editor/screens/widget_editor_screen.dart';
import '../../core/utils/prefs_keys.dart';
import '../../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../features/notes/screens/note_editor_screen.dart';
import '../../features/notes/screens/notes_biometric_gate.dart';
import '../../features/notes/screens/notes_filter_screen.dart';
import '../../features/notes/screens/notes_landing_screen.dart';
import '../../features/reminders/screens/add_edit_reminder_screen.dart';
import '../../features/reminders/data/reminder.dart';
import '../../features/reminders/screens/reminders_landing_screen.dart';
import '../../features/upcoming_events/screens/upcoming_events_full_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/tools/tools_hub_screen.dart';
import '../../features/tools/currency_converter/currency_converter_screen.dart';
import '../../features/tools/emi_calculator/emi_calculator_screen.dart';
import '../../features/tools/sip_calculator/sip_calculator_screen.dart';
import '../../features/tools/sip_amount_finder/sip_amount_finder_screen.dart';
import '../../features/tools/tip_calculator/tip_calculator_screen.dart';
import '../../features/tools/discount_calculator/discount_calculator_screen.dart';
import '../../features/tools/gst_calculator/gst_calculator_screen.dart';
import '../../features/tools/fd_rd_calculator/fd_rd_calculator_screen.dart';
import '../../features/tools/ppf_calculator/ppf_calculator_screen.dart';
import '../../features/tools/salary_calculator/salary_calculator_screen.dart';
import '../../features/tools/inflation_calculator/inflation_calculator_screen.dart';
import '../../features/tools/breakeven_calculator/breakeven_calculator_screen.dart';
import '../../features/tools/hra_calculator/hra_calculator_screen.dart';
import '../../features/tools/bill_splitter/add_edit_bill_screen.dart';
import '../../features/tools/bill_splitter/bill_splitter_screen.dart';
import '../../features/tools/loan_prepayment/loan_prepayment_screen.dart';
import '../../features/tools/lumpsum_vs_sip/lumpsum_vs_sip_screen.dart';
import '../../features/tools/goal_planner/goal_planner_screen.dart';
import '../../features/tools/retirement_corpus/retirement_corpus_screen.dart';
import '../../features/tools/saved/saved_calculations_screen.dart';

/// Parses the optional `?savedId=` query param used to open a calculator
/// pre-filled from a SavedCalculation.
int? _savedId(GoRouterState state) =>
    int.tryParse(state.uri.queryParameters['savedId'] ?? '');

final rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _shellHistoryKey = GlobalKey<NavigatorState>(debugLabel: 'history');
final _shellAnalyticsKey = GlobalKey<NavigatorState>(debugLabel: 'analytics');
final _shellMoreKey = GlobalKey<NavigatorState>(debugLabel: 'more');
final shellNavigatorKeys = [
  _shellDashboardKey,
  _shellHistoryKey,
  _shellAnalyticsKey,
  _shellMoreKey,
];

/// A [Listenable] that notifies when a [Stream] emits a value.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: GoRouterRefreshStream(
      ref.watch(recurringProcessResultProvider.notifier).stream,
    ),
    redirect: (context, state) async {
      final prefs = await SharedPreferences.getInstance();
      final onboarded = prefs.getBool(PrefsKeys.onboarded) ?? false;

      // Normalize deep link paths from app shortcuts (kuber://app/<path>)
      // GoRouter sees the path portion; remap any shortcut aliases here.
      if (state.matchedLocation == '/ask-kuber') return '/more/ask-kuber';

      // Allow splash screen to show
      if (state.matchedLocation == '/splash') return null;

      // If opening for the first time, go to onboarding
      if (!onboarded && !state.matchedLocation.startsWith('/onboarding')) {
        return '/onboarding';
      }

      // If onboarded and trying to go to root, check for recurring transactions
      if (onboarded && state.matchedLocation == '/') {
        final missedCount = ref.read(recurringProcessResultProvider);
        final backupDue = ref.read(automaticBackupDueProvider);
        if (missedCount > 0 || backupDue) {
          return '/recurring-loader';
        }
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => OnboardingFlow(
          isReplay: state.uri.queryParameters['replay'] == 'true',
        ),
      ),
      GoRoute(
        path: '/tutorial',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const TutorialChapterScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        parentNavigatorKey: rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: AddTransactionScreen(
            transaction: state.extra as Transaction?,
            initialType: state.uri.queryParameters['type'],
            initialAccountId: int.tryParse(
              state.uri.queryParameters['accountId'] ?? '',
            ),
            initialAmount: double.tryParse(
              state.uri.queryParameters['amount'] ?? '',
            ),
            initialName: state.uri.queryParameters['name'],
            initialCategoryId: int.tryParse(
              state.uri.queryParameters['categoryId'] ?? '',
            ),
            sourceNoteId: state.uri.queryParameters['sourceNoteId'],
            sourceReminderId: int.tryParse(
              state.uri.queryParameters['reminderId'] ?? '',
            ),
          ),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: animation,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: child,
            );
          },
        ),
      ),
      GoRoute(
        path: '/analytics/filter',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AnalyticsFilterScreen(),
      ),
      GoRoute(
        path: '/history/filter',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AdvancedFilterScreen(),
      ),

      GoRoute(
        path: '/category/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) {
          final args = state.extra as CategoryRouteArgs?;
          return AddEditCategoryScreen(
            existingCategory: args?.category,
            defaultType: args?.defaultType,
            returnToCategoryPicker: args?.returnToCategoryPicker ?? false,
          );
        },
      ),

      GoRoute(
        path: '/accounts/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const AddEditAccountScreen(),
      ),
      GoRoute(
        path: '/accounts/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) =>
            EditAccountScreen(account: state.extra as Account),
      ),

      GoRoute(
        path: '/recurring/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => AddRecurringScreen(
          amountPrefill:
              double.tryParse(state.uri.queryParameters['amount'] ?? ''),
          categoryPrefill:
              int.tryParse(state.uri.queryParameters['categoryId'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/recurring/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            AddRecurringScreen(existingRule: state.extra as RecurringRule?),
      ),

      GoRoute(
        path: '/recurring-loader',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const RecurringLoaderScreen(),
      ),
      GoRoute(
        name: 'permissions',
        path: '/security',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const PermissionsScreen(),
      ),
      GoRoute(
        name: 'about',
        path: '/more/about',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const AboutScreen(),
      ),
      GoRoute(
        path: '/more/feedback',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            FeedbackScreen(prefill: state.uri.queryParameters['prefill']),
      ),
      StatefulShellRoute(
        builder: (context, state, navigationShell) =>
            navigationShell, // The shell is rendered via navigatorContainerBuilder
        navigatorContainerBuilder: (context, navigationShell, children) =>
            AppScaffold(navigationShell: navigationShell, children: children),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellDashboardKey,
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) =>
                    const ScreenEntrance(id: 'home', child: DashboardScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellHistoryKey,
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) =>
                    const ScreenEntrance(id: 'history', child: HistoryScreen()),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellAnalyticsKey,
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const ScreenEntrance(
                  id: 'analytics',
                  child: AnalyticsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellMoreKey,
            routes: [
              GoRoute(
                path: '/more',
                builder: (context, state) =>
                    const ScreenEntrance(id: 'more', child: MoreScreen()),
                routes: [
                  GoRoute(
                    path: 'accounts',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const AccountsScreen(),
                  ),
                  GoRoute(
                    path: 'categories',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const CategoriesScreen(),
                  ),
                  GoRoute(
                    path: 'tags',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const TagsScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'how-to-use',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const HowToUseScreen(),
                  ),
                  GoRoute(
                    path: 'data',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const DataManagementScreen(),
                    routes: [
                      GoRoute(
                        path: 'automatic-backups',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, _) => const AutomaticBackupsScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'recurring',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const RecurringScreen(),
                  ),
                  GoRoute(
                    path: 'budgets',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const BudgetsScreen(),
                  ),
                  GoRoute(
                    path: 'ledger',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const LedgerScreen(),
                  ),
                  GoRoute(
                    path: 'loans',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const LoansScreen(),
                  ),
                  GoRoute(
                    path: 'investments',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const InvestmentsScreen(),
                  ),
                  GoRoute(
                    path: 'charts',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const ChartsScreen(),
                  ),
                  GoRoute(
                    path: 'ask-kuber',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const AskKuberScreen(),
                  ),
                  GoRoute(
                    path: 'sms-import',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, state) => SmsImportScreen(
                      initialTab: switch (
                          state.uri.queryParameters['tab']) {
                        'imported' => SmsImportTab.imported,
                        'dismissed' => SmsImportTab.dismissed,
                        _ => SmsImportTab.unreviewed,
                      },
                    ),
                  ),
                  GoRoute(
                    path: 'troubleshoot',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const TroubleshootScreen(),
                  ),
                  GoRoute(
                    path: 'stories-archive',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const StoryArchiveScreen(),
                  ),
                  GoRoute(
                    path: 'tools',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const ToolsHubScreen(),
                  ),
                  GoRoute(
                    path: 'notes',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const NotesBiometricGate(
                      child: NotesLandingScreen(),
                    ),
                    routes: [
                      GoRoute(
                        path: 'filter',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, _) => const NotesFilterScreen(),
                      ),
                    ],
                  ),
                  GoRoute(
                    path: 'reminders',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, state) => RemindersLandingScreen(
                      openReminderId: int.tryParse(
                        state.uri.queryParameters['open'] ?? '',
                      ),
                    ),
                  ),
                  GoRoute(
                    path: 'upcoming-events',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const UpcomingEventsFullScreen(),
                  ),

                  GoRoute(
                    path: 'tools/currency-converter',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const CurrencyConverterScreen(),
                  ),
                  GoRoute(
                    path: 'tools/emi-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) =>
                        EmiCalculatorScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/sip-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) =>
                        InvestmentReturnsCalculatorScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/sip-amount-finder',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) =>
                        SipAmountFinderScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/tip-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const TipCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/discount-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const DiscountCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/gst-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) => GstCalculatorScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/fd-rd-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) =>
                        FdRdCalculatorScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/ppf-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) => PpfCalculatorScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/salary-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) =>
                        SalaryCalculatorScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/inflation-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) =>
                        InflationCalculatorScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/loan-prepayment',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) =>
                        LoanPrepaymentScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/lumpsum-vs-sip',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) => LumpsumVsSipScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/goal-planner',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) => GoalPlannerScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/retirement-corpus',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) =>
                        RetirementCorpusScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/saved-calculations',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) => SavedCalculationsScreen(
                      initialTool: s.uri.queryParameters['tool'],
                    ),
                  ),
                  GoRoute(
                    path: 'tools/breakeven-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const BreakevenCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/hra-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, s) => HraCalculatorScreen(savedId: _savedId(s)),
                  ),
                  GoRoute(
                    path: 'tools/split-calculator',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const BillSplitterScreen(),
                  ),
                  GoRoute(
                    path: 'search',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const MoreSearchScreen(),
                  ),
                  GoRoute(
                    path: 'dev-tools',
                    parentNavigatorKey: rootNavigatorKey,
                    builder: (_, _) => const DevToolsScreen(),
                    routes: [
                      GoRoute(
                        path: 'db-explorer',
                        parentNavigatorKey: rootNavigatorKey,
                        builder: (_, _) => const DbExplorerScreen(),
                        routes: [
                          GoRoute(
                            path: ':collection',
                            parentNavigatorKey: rootNavigatorKey,
                            builder: (_, state) => DbCollectionScreen(
                              collectionName:
                                  state.pathParameters['collection']!,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/budgets/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            AddEditBudgetScreen(preselectedCategory: state.extra as Category?),
      ),
      GoRoute(
        path: '/budgets/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            AddEditBudgetScreen(existingBudget: state.extra as Budget?),
      ),
      GoRoute(
        path: '/more/tools/split-calculator/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const AddEditBillScreen(),
      ),

      GoRoute(
        path: '/ledger/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra;
          return AddLedgerScreen(
            prefill: extra is LedgerPrefill ? extra : null,
            amountPrefill:
                double.tryParse(state.uri.queryParameters['amount'] ?? ''),
          );
        },
      ),
      GoRoute(
        path: '/ledger/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            AddLedgerScreen(existing: state.extra as Ledger?),
      ),
      GoRoute(
        path: '/loans/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => AddLoanScreen(
          amountPrefill:
              double.tryParse(state.uri.queryParameters['amount'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/loans/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => AddLoanScreen(existing: state.extra as Loan?),
      ),
      GoRoute(
        path: '/investments/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => AddInvestmentScreen(
          amountPrefill:
              double.tryParse(state.uri.queryParameters['amount'] ?? ''),
        ),
      ),
      GoRoute(
        path: '/investments/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            AddInvestmentScreen(existing: state.extra as Investment?),
      ),
      GoRoute(
        path: '/notes/editor',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) => NotesBiometricGate(
          child: NoteEditorScreen(
            noteId:
                int.tryParse(state.uri.queryParameters['id'] ?? '') ?? -1,
          ),
        ),
      ),
      GoRoute(
        path: '/reminders/add',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const AddEditReminderScreen(),
      ),
      GoRoute(
        path: '/reminders/edit',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, state) =>
            AddEditReminderScreen(existing: state.extra as Reminder?),
      ),
      GoRoute(
        path: '/widget-editor/home',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) =>
            const WidgetEditorScreen(scope: WidgetEditorScope.home),
      ),
      GoRoute(
        path: '/widget-editor/analytics',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) =>
            const WidgetEditorScreen(scope: WidgetEditorScope.analytics),
      ),
    ],
  );
});
