// lib/core/widgets/main_scaffold.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kampus_koin_app/features/goals/widgets/create_goal_form.dart';

class MainScaffold extends StatelessWidget {
  final Widget child;

  const MainScaffold({super.key, required this.child});

  // Helper method to determine the current tab index from the route
  int _calculateCurrentIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/marketplace')) return 1;
    if (location.startsWith('/profile')) return 2;
    return 0;
  }

  // Helper method to navigate when a tab is tapped
  void _onTabTapped(int index, BuildContext context) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/marketplace');
        break;
      case 2:
        context.go('/profile');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateCurrentIndex(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Consistent app background
      body: child,
      
      // Gradient Floating Action Button (Only shown on Home tab)
      floatingActionButton: currentIndex == 0
          ? Container(
              height: 60,
              width: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.primary.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent, // Allows rounded corners
                    builder: (context) {
                      return const CreateGoalForm();
                    },
                  );
                },
                backgroundColor: Colors.transparent, // Show gradient
                elevation: 0,
                child: const Icon(Icons.add_rounded, color: Colors.white, size: 32),
              ),
            )
          : null,
      // Positioned at bottom-right to avoid blocking the center 'Market' tab
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Modern Bottom Navigation Bar
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: (index) => _onTabTapped(index, context),
          backgroundColor: Colors.white,
          elevation: 0, // Handled by Container shadow
          selectedItemColor: colorScheme.primary,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12),
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_rounded),
              label: 'Market',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_rounded),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}