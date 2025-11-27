// lib/routing/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/features/settings/screens/settings_screen.dart';
import 'package:shared_preferences/shared_preferences.dart'; // <-- IMPORT THIS

import 'package:kampus_koin_app/core/models/order_model.dart';
import 'package:kampus_koin_app/core/widgets/main_scaffold.dart';
import 'package:kampus_koin_app/features/auth/providers/auth_notifier.dart';
import 'package:kampus_koin_app/features/auth/screens/login_screen.dart';
import 'package:kampus_koin_app/features/auth/screens/register_screen.dart';
import 'package:kampus_koin_app/features/home/screens/home_screen.dart';
import 'package:kampus_koin_app/features/marketplace/screens/marketplace_screen.dart';
import 'package:kampus_koin_app/features/marketplace/screens/order_pickup_screen.dart';
import 'package:kampus_koin_app/features/onboarding/screens/onboarding_screen.dart'; // <-- IMPORT THIS
import 'package:kampus_koin_app/features/profile/screens/profile_screen.dart';
import 'package:kampus_koin_app/features/profile/screens/edit_profile_screen.dart';

class GoRouterRefreshNotifier extends ChangeNotifier {
  final Ref _ref;
  GoRouterRefreshNotifier(this._ref) {
    // Listen to the AuthNotifier provider
    _ref.listen<AuthState>(authNotifierProvider, (_, __) {
      notifyListeners();
    });
  }
}

final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshNotifier(ref);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refreshNotifier,
    
    // --- REDIRECT LOGIC ---
    redirect: (BuildContext context, GoRouterState state) async {
      final authStatus = ref.read(authNotifierProvider).status;
      final bool loggedIn = authStatus == AuthStatus.authenticated;
      
      // Check Shared Prefs for onboarding
      final prefs = await SharedPreferences.getInstance();
      final bool hasSeenOnboarding = prefs.getBool('hasSeenOnboarding') ?? false;

      final bool onOnboarding = state.matchedLocation == '/onboarding';
      final bool loggingIn = state.matchedLocation == '/login';
      final bool registering = state.matchedLocation == '/register';
      final bool isPublicRoute = loggingIn || registering || onOnboarding;

      // 1. ONBOARDING CHECK (Highest Priority)
      // If user hasn't seen onboarding, force them there
      if (!hasSeenOnboarding && !onOnboarding) {
        return '/onboarding';
      }

      // 2. If they HAVE seen onboarding but are currently ON it, send to login
      // (This prevents getting stuck in a loop after clicking "Get Started")
      if (hasSeenOnboarding && onOnboarding) {
        return '/login';
      }

      // 3. AUTH CHECK
      // If not logged in and trying to access a protected route
      if (!loggedIn && !isPublicRoute) {
        return '/login';
      }

      // 4. ALREADY LOGGED IN CHECK
      // If logged in and trying to access login/register/onboarding
      if (loggedIn && isPublicRoute) {
        return '/home';
      }

      return null;
    },

    routes: [
      // --- Public Routes ---
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/login', 
        builder: (context, state) => const LoginScreen()
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),

      // --- Fullscreen Protected Routes (No Bottom Nav) ---
      GoRoute(
        path: '/order-pickup',
        builder: (context, state) {
          final order = state.extra as Order;
          return OrderPickupScreen(order: order);
        },
      ),

      // --- Shell Routes (With Bottom Nav) ---
      ShellRoute(
        builder: (context, state, child) {
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
          GoRoute(
        path: '/edit-profile',
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
  path: '/settings',
  builder: (context, state) => const SettingsScreen(),
),
        ],
      ), 
    ],

    errorBuilder: (context, state) =>
        Scaffold(body: Center(child: Text('Page not found: ${state.error}'))),
  );
});