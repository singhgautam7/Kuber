import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/analytics/screens/analytics_filter_screen.dart';
import '../../features/history/screens/advanced_filter_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/setup_screen.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/transactions/screens/transaction_list_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../features/accounts/data/account.dart';
import '../../features/accounts/screens/accounts_screen.dart';
import '../../features/accounts/screens/add_edit_account_screen.dart';
import '../../features/more/screens/more_screen.dart';
import '../../features/more/screens/more_search_screen.dart';
import '../../features/more/screens/about_screen.dart';
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
import '../../features/more/screens/ask_kuber_screen.dart';
import '../../features/more/screens/troubleshoot_screen.dart';
import '../../features/budgets/data/budget.dart';
import '../../features/dev/screens/dev_tools_screen.dart';
import '../../features/dev/screens/db_explorer_screen.dart';
import '../../features/dev/screens/db_collection_screen.dart';
import '../../features/budgets/screens/budgets_screen.dart';
import '../../features/budgets/screens/add_edit_budget_screen.dart';
import '../../core/utils/prefs_keys.dart';
import '../../main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';

import '../../features/splash/screens/splash_screen.dart';
import '../../features/history/providers/selection_provider.dart';
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

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellDashboardKey = GlobalKey<NavigatorState>(debugLabel: 'dashboard');
final _shellHistoryKey = GlobalKey<NavigatorState>(debugLabel: 'history');
final _shellAnalyticsKey = GlobalKey<NavigatorState>(debugLabel: 'analytics');
final _shellMoreKey = GlobalKey<NavigatorState>(debugLabel: 'more');

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
    navigatorKey: _rootNavigatorKey,
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
        if (missedCount > 0) return '/recurring-loader';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/splash',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/onboarding',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/setup',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: '/add-transaction',
        parentNavigatorKey: _rootNavigatorKey,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: AddTransactionScreen(
            transaction: state.extra as Transaction?,
            initialType: state.uri.queryParameters['type'],
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
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AnalyticsFilterScreen(),
      ),
      GoRoute(
        path: '/history/filter',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdvancedFilterScreen(),
      ),

      GoRoute(
        path: '/category/add',
        parentNavigatorKey: _rootNavigatorKey,
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
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AddEditAccountScreen(),
      ),
      GoRoute(
        path: '/accounts/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) =>
            AddEditAccountScreen(account: state.extra as Account?),
      ),

      GoRoute(
        path: '/recurring/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const AddRecurringScreen(),
      ),
      GoRoute(
        path: '/recurring/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            AddRecurringScreen(existingRule: state.extra as RecurringRule?),
      ),

      GoRoute(
        path: '/recurring-loader',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const RecurringLoaderScreen(),
      ),
      GoRoute(
        name: 'permissions',
        path: '/security',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const PermissionsScreen(),
      ),
      GoRoute(
        name: 'about',
        path: '/more/about',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const AboutScreen(),
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
                builder: (context, state) => const _RootTabBackScope(
                  tabIndex: 0,
                  child: DashboardScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellHistoryKey,
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const _RootTabBackScope(
                  tabIndex: 1,
                  child: HistoryScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellAnalyticsKey,
            routes: [
              GoRoute(
                path: '/analytics',
                builder: (context, state) => const _RootTabBackScope(
                  tabIndex: 2,
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
                    const _RootTabBackScope(tabIndex: 3, child: MoreScreen()),
                routes: [
                  GoRoute(
                    path: 'accounts',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const AccountsScreen(),
                  ),
                  GoRoute(
                    path: 'categories',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const CategoriesScreen(),
                  ),
                  GoRoute(
                    path: 'tags',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const TagsScreen(),
                  ),
                  GoRoute(
                    path: 'settings',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const SettingsScreen(),
                  ),
                  GoRoute(
                    path: 'how-to-use',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const HowToUseScreen(),
                  ),
                  GoRoute(
                    path: 'data',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const DataManagementScreen(),
                  ),
                  GoRoute(
                    path: 'recurring',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const RecurringScreen(),
                  ),
                  GoRoute(
                    path: 'budgets',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const BudgetsScreen(),
                  ),
                  GoRoute(
                    path: 'ledger',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const LedgerScreen(),
                  ),
                  GoRoute(
                    path: 'loans',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const LoansScreen(),
                  ),
                  GoRoute(
                    path: 'investments',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const InvestmentsScreen(),
                  ),
                  GoRoute(
                    path: 'charts',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const ChartsScreen(),
                  ),
                  GoRoute(
                    path: 'ask-kuber',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const AskKuberScreen(),
                  ),
                  GoRoute(
                    path: 'troubleshoot',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const TroubleshootScreen(),
                  ),
                  GoRoute(
                    path: 'tools',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const ToolsHubScreen(),
                  ),

                  GoRoute(
                    path: 'tools/currency-converter',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const CurrencyConverterScreen(),
                  ),
                  GoRoute(
                    path: 'tools/emi-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const EmiCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/sip-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) =>
                        const InvestmentReturnsCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/sip-amount-finder',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const SipAmountFinderScreen(),
                  ),
                  GoRoute(
                    path: 'tools/tip-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const TipCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/discount-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const DiscountCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/gst-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const GstCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/fd-rd-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const FdRdCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/ppf-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const PpfCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/salary-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const SalaryCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/inflation-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const InflationCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/breakeven-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const BreakevenCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/hra-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const HraCalculatorScreen(),
                  ),
                  GoRoute(
                    path: 'tools/split-calculator',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const BillSplitterScreen(),
                  ),
                  GoRoute(
                    path: 'search',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const MoreSearchScreen(),
                  ),
                  GoRoute(
                    path: 'dev-tools',
                    parentNavigatorKey: _rootNavigatorKey,
                    builder: (_, _) => const DevToolsScreen(),
                    routes: [
                      GoRoute(
                        path: 'db-explorer',
                        parentNavigatorKey: _rootNavigatorKey,
                        builder: (_, _) => const DbExplorerScreen(),
                        routes: [
                          GoRoute(
                            path: ':collection',
                            parentNavigatorKey: _rootNavigatorKey,
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
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            AddEditBudgetScreen(preselectedCategory: state.extra as Category?),
      ),
      GoRoute(
        path: '/budgets/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            AddEditBudgetScreen(existingBudget: state.extra as Budget?),
      ),
      GoRoute(
        path: '/more/tools/split-calculator/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const AddEditBillScreen(),
      ),

      GoRoute(
        path: '/ledger/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) {
          final extra = state.extra;
          return AddLedgerScreen(
            prefill: extra is LedgerPrefill ? extra : null,
          );
        },
      ),
      GoRoute(
        path: '/ledger/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            AddLedgerScreen(existing: state.extra as Ledger?),
      ),
      GoRoute(
        path: '/loans/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const AddLoanScreen(),
      ),
      GoRoute(
        path: '/loans/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => AddLoanScreen(existing: state.extra as Loan?),
      ),
      GoRoute(
        path: '/investments/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const AddInvestmentScreen(),
      ),
      GoRoute(
        path: '/investments/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) =>
            AddInvestmentScreen(existing: state.extra as Investment?),
      ),
    ],
  );
});

class _RootTabBackScope extends ConsumerWidget {
  final int tabIndex;
  final Widget child;

  const _RootTabBackScope({required this.tabIndex, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSelectionMode = ref.watch(isSelectionModeProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (tabIndex == 1 && isSelectionMode) {
          ref.read(transactionSelectionProvider.notifier).clear();
          return;
        }

        if (tabIndex == 0) {
          SystemNavigator.pop();
          return;
        }

        context.go('/');
      },
      child: child,
    );
  }
}
