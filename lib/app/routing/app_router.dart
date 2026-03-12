import 'package:amaris_test/app/routing/app_destinations.dart';
import 'package:amaris_test/core/ui/layout/adaptive_app_shell.dart';
import 'package:amaris_test/features/funds/presentation/funds_page.dart';
import 'package:amaris_test/features/home/presentation/home_page.dart';
import 'package:amaris_test/features/settings/presentation/settings_page.dart';
import 'package:amaris_test/features/transactions/presentation/transactions_page.dart';
import 'package:go_router/go_router.dart';

GoRouter buildAppRouter() {
  return GoRouter(
    initialLocation: AppRoutePaths.home,
    routes: <RouteBase>[
      ShellRoute(
        builder: (context, state, child) {
          return AdaptiveAppShell(
            currentLocation: state.matchedLocation,
            child: child,
          );
        },
        routes: <RouteBase>[
          GoRoute(
            path: AppRoutePaths.home,
            builder: (context, state) => const HomePage(),
          ),
          GoRoute(
            path: AppRoutePaths.funds,
            builder: (context, state) => const FundsPage(),
          ),
          GoRoute(
            path: AppRoutePaths.transactions,
            builder: (context, state) => const TransactionsPage(),
          ),
          GoRoute(
            path: AppRoutePaths.settings,
            builder: (context, state) => const SettingsPage(),
          ),
        ],
      ),
    ],
  );
}
