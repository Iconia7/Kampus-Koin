// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/models/goal_model.dart';
import 'package:kampus_koin_app/features/goals/widgets/deposit_form.dart';
import 'package:kampus_koin_app/features/home/providers/total_savings_provider.dart';
import 'package:kampus_koin_app/features/home/providers/user_data_provider.dart';
import 'package:kampus_koin_app/features/profile/providers/transactions_provider.dart'; // <-- IMPORT THIS
import '../../auth/providers/auth_notifier.dart';
import 'package:kampus_koin_app/features/home/providers/goals_provider.dart';
import 'package:kampus_koin_app/features/goals/providers/goal_notifier.dart';
// --- NEW IMPORTS ---
import 'package:kampus_koin_app/features/home/widgets/user_badge.dart';
import 'package:kampus_koin_app/features/home/widgets/savings_chart.dart';
// -------------------
import 'package:intl/intl.dart';
import 'dart:ui';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    final goalsData = ref.watch(goalsProvider);
    final transactionsData = ref.watch(transactionsProvider); // <-- WATCH THIS
    final totalSavings = ref.watch(totalSavingsProvider);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_KE', symbol: 'KES ');

    // Listen for errors from the goal notifier (for deletions)
    ref.listen<GoalCreationState>(goalNotifierProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colorScheme.surface,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: Icon(Icons.logout_rounded, color: colorScheme.primary),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(userDataProvider);
          ref.invalidate(goalsProvider);
          ref.invalidate(transactionsProvider); // Refresh tx for the chart
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: userData.when(
                loading: () => const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50.0),
                    child: CircularProgressIndicator(),
                  ),
                ),
                error: (err, stack) =>
                    Center(child: Text('Error: ${err.toString()}')),
                data: (user) {
                  return Stack(
                    children: [
                      // Gradient Background (Taller to accommodate chart)
                      Container(
                        height: 440, // Increased height slightly
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.primary.withOpacity(0.8),
                              colorScheme.secondary,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(60),
                            bottomRight: Radius.circular(60),
                          ),
                        ),
                      ),
                      // Decorative circles
                      Positioned(
                        top: -50,
                        right: -50,
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 100,
                        left: -30,
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 80),
                            // Welcome Header
                            Text(
                              'Welcome back,',
                              style: textTheme.bodyLarge?.copyWith(
                                fontSize: 16,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            const SizedBox(height: 4),
                            
                            // --- MODIFIED: Name Row with Badge ---
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  user.name,
                                  style: textTheme.displayLarge?.copyWith(
                                    color: Colors.white,
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                // --- NEW BADGE ---
                                UserBadge(koinScore: user.koinScore),
                                // -----------------
                              ],
                            ),
                            
                            const SizedBox(height: 32),

                            // Glassmorphic Stats Container
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter:
                                    ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                  ),
                                                  child: const Icon(
                                                    Icons.savings_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Total Savings',
                                                  style: textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              currencyFormatter
                                                  .format(totalSavings),
                                              style: textTheme.headlineLarge
                                                  ?.copyWith(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: 1,
                                        height: 60,
                                        color: Colors.white.withOpacity(0.3),
                                      ),
                                      const SizedBox(width: 24),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withOpacity(0.2),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: const Icon(
                                                    Icons.stars_rounded,
                                                    color: Colors.white,
                                                    size: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 12),
                                                Text(
                                                  'Koin Score',
                                                  style: textTheme.bodyMedium
                                                      ?.copyWith(
                                                    color: Colors.white
                                                        .withOpacity(0.9),
                                                    fontWeight:
                                                        FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              user.koinScore.toString(),
                                              style: textTheme.headlineLarge
                                                  ?.copyWith(
                                                color: Colors.white,
                                                fontSize: 28,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                            const SizedBox(height: 24),

                            // --- NEW: SAVINGS CHART ---
                            transactionsData.when(
                                data: (transactions) => SavingsChart(transactions: transactions),
                                loading: () => const SizedBox(height: 220, child: Center(child: CircularProgressIndicator())),
                                error: (_, __) => const SizedBox.shrink()
                            ),
                            // --------------------------

                            const SizedBox(height: 32),

                            // Section Header
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Savings Goals',
                                  style: textTheme.headlineMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 22,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        colorScheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: goalsData.when(
                                    data: (goals) => Text(
                                      '${goals.length} active',
                                      style: textTheme.bodySmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    loading: () => const SizedBox(
                                      width: 60,
                                      child: Text('...'),
                                    ),
                                    error: (_, __) => const Text('0'),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Goals List
            goalsData.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Could not load goals: $err')),
              ),
              data: (goals) {
                if (goals.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          children: [
                            Icon(
                              Icons.flag_outlined,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              "No goals yet",
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Create your first savings goal to get started",
                              style: TextStyle(
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                // This is a scrolling list that is built efficiently
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final goal = goals[index];
                        return GoalListItem(goal: goal);
                      },
                      childCount: goals.length,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
// ... (GoalListItem remains the same as your previous version)

// --- UPDATED WIDGET: GoalListItem (Now a ConsumerWidget) ---
class GoalListItem extends ConsumerWidget { // <-- CHANGED
  final Goal goal;

  const GoalListItem({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) { // <-- ADDED ref
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'Ksh ',
    );
    final bool isComplete = goal.progress >= 1.0;
    final colorScheme = Theme.of(context).colorScheme;
    final progressPercentage = (goal.progress * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: isComplete
                ? Colors.green.withOpacity(0.2)
                : colorScheme.primary.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Background Progress Indicator
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: MediaQuery.of(context).size.width * goal.progress,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isComplete
                        ? [
                            Colors.green.withOpacity(0.1),
                            Colors.green.withOpacity(0.05)
                          ]
                        : [
                            colorScheme.primary.withOpacity(0.1),
                            colorScheme.primary.withOpacity(0.05),
                          ],
                  ),
                ),
              ),
            ),
            
            // --- NEW: DELETE BUTTON ---
            Positioned(
              top: -5,
              right: -5,
              child: IconButton(
                icon: Icon(Icons.delete_outline_rounded, color: Colors.grey[400]),
                iconSize: 20,
                onPressed: () {
                  // Show confirmation dialog
                  showDialog(
                    context: context,
                    builder: (BuildContext dialogContext) {
                      return AlertDialog(
                        title: const Text('Delete Goal?'),
                        content: Text('Are you sure you want to delete the goal "${goal.name}"? This action cannot be undone.'),
                        actions: [
                          TextButton(
                            child: const Text('Cancel'),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // Close the dialog
                            },
                          ),
                          TextButton(
                            child: Text('Delete', style: TextStyle(color: colorScheme.error)),
                            onPressed: () {
                              Navigator.of(dialogContext).pop(); // Close the dialog
                              // Call the notifier to delete the goal
                              ref.read(goalNotifierProvider.notifier).deleteGoal(goal.id);
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
            // ------------------------
            
            // Content
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              goal.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${currencyFormatter.format(goal.currentAmount)} of ${currencyFormatter.format(goal.targetAmount)}',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                            ),
                          ],
                        ),
                      ),
                      // Circular Progress
                      SizedBox(
                        width: 52,
                        height: 52,
                        child: Stack(
                          alignment: Alignment.center, // <--- 1. Centers everything
                          fit: StackFit.expand,
                          children: [
                            CircularProgressIndicator(
                              value: goal.progress,
                              strokeWidth: 5,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                isComplete
                                    ? Colors.green
                                    : colorScheme.primary,
                              ),
                            ),
                            Center(
                              child: Text(
                                '$progressPercentage%',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: isComplete
                                      ? Colors.green
                                      : colorScheme.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: isComplete
                        ? Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Goal Complete! 🎉',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (ctx) => Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(20),
                                    ),
                                  ),
                                  child: DepositForm(
                                    goalId: goal.id,
                                    goalName: goal.name,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 0,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.add_circle_outline, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  'Add Deposit',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}