// lib/routing/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/widgets/main_scaffold.dart';
import 'package:kampus_koin_app/features/auth/providers/auth_notifier.dart';
import 'package:kampus_koin_app/features/auth/screens/login_screen.dart';
import 'package:kampus_koin_app/features/home/screens/home_screen.dart';
import 'package:kampus_koin_app/features/marketplace/screens/marketplace_screen.dart';
import 'package:kampus_koin_app/features/profile/screens/profile_screen.dart';
import 'package:kampus_koin_app/features/auth/screens/register_screen.dart';
// Import other screens as you create them (e.g., RegisterScreen)

class GoRouterRefreshNotifier extends ChangeNotifier {
  final Ref _ref;
  GoRouterRefreshNotifier(this._ref) {
    // Listen to the AuthNotifier provider
    _ref.listen<AuthState>(authNotifierProvider, (_, __) {
      // When the AuthState changes, notify listeners (GoRouter)
      notifyListeners();
    });
  }
}

// Provider to easily access the router
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier, // Start at the login screen
    // Redirect logic: based on auth state
    redirect: (BuildContext context, GoRouterState state) {
      final authStatus = ref.read(authNotifierProvider).status;
      final bool loggedIn = authStatus == AuthStatus.authenticated;
      final bool loggingIn = state.matchedLocation == '/login';
      final bool isRegistering =
          state.matchedLocation == '/register'; // <-- ADD THIS
      final bool isPublicRoute = loggingIn || isRegistering;

      // If not logged in and trying to access a protected route, redirect to login
      if (!loggedIn && !isPublicRoute) {
        return '/login';
      }
      // If logged in and trying to access login/register, redirect to home
      if (loggedIn && isPublicRoute) {
        return '/home';
      }

      // No redirect needed
      return null;
    },

    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(
        // <-- ADD THIS NEW ROUTE
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) {
          // The ShellRoute builder returns our MainScaffold
          return MainScaffold(child: child);
        },
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/marketplace',
            builder: (context, state) => const MarketplaceScreen(),
          ),
          GoRoute(
            path: '/profile',
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
    ],

    // Optional: Error page
    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
});
