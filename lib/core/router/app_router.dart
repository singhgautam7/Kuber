import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/analytics/screens/analytics_screen.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/onboarding/screens/welcome_screen.dart';
import '../../features/onboarding/screens/setup_screen.dart';
import '../../features/splash/screens/splash_screen.dart';
import '../../features/transactions/data/transaction.dart';
import '../../features/transactions/screens/transaction_list_screen.dart';
import '../../features/transactions/screens/add_transaction_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import '../../features/accounts/screens/accounts_screen.dart';
import '../../features/more/screens/more_screen.dart';
import '../../features/more/screens/categories_screen.dart';
import '../../features/more/screens/tags_screen.dart';
import '../../features/more/screens/how_to_use_screen.dart';
import '../../features/more/screens/add_edit_category_screen.dart';
import '../../features/recurring/data/recurring_rule.dart';
import '../../features/recurring/screens/add_recurring_screen.dart';
import '../../features/recurring/screens/recurring_loader_screen.dart';
import '../../features/recurring/screens/recurring_screen.dart';
import '../../features/settings/screens/settings_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

GoRouter createRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/splash',
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
        builder: (context, state) => AddTransactionScreen(
          transaction: state.extra as Transaction?,
        ),
      ),
      GoRoute(
        path: '/more/accounts',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const AccountsScreen(),
      ),
      GoRoute(
        path: '/more/categories',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const CategoriesScreen(),
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
        path: '/more/tags',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const TagsScreen(),
      ),
      GoRoute(
        path: '/more/settings',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const SettingsScreen(),
      ),
      GoRoute(
        path: '/more/how-to-use',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const HowToUseScreen(),
      ),
      GoRoute(
        path: '/recurring/add',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const AddRecurringScreen(),
      ),
      GoRoute(
        path: '/recurring/edit',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, state) => AddRecurringScreen(
          existingRule: state.extra as RecurringRule?,
        ),
      ),
      GoRoute(
        path: '/more/recurring',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const RecurringScreen(),
      ),
      GoRoute(
        path: '/recurring-loader',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (_, _) => const RecurringLoaderScreen(),
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const DashboardScreen(),
          ),
          GoRoute(
            path: '/history',
            builder: (context, state) => const HistoryScreen(),
          ),
          GoRoute(
            path: '/analytics',
            builder: (context, state) => const AnalyticsScreen(),
          ),
          GoRoute(
            path: '/accounts',
            builder: (context, state) => const MoreScreen(),
          ),
        ],
      ),
    ],
  );
}
