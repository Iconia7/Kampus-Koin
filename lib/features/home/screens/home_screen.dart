// lib/features/home/screens/home_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/models/goal_model.dart';
import 'package:kampus_koin_app/core/services/notification_service.dart'; // Import Notification Service
import 'package:kampus_koin_app/features/goals/widgets/deposit_form.dart';
import 'package:kampus_koin_app/features/home/providers/total_savings_provider.dart';
import 'package:kampus_koin_app/features/home/providers/user_data_provider.dart';
import 'package:kampus_koin_app/features/marketplace/providers/products_provider.dart'; // Import Products Provider
import 'package:kampus_koin_app/features/profile/providers/transactions_provider.dart';
import '../../auth/providers/auth_notifier.dart';
import 'package:kampus_koin_app/features/home/providers/goals_provider.dart';
import 'package:kampus_koin_app/features/goals/providers/goal_notifier.dart';
import 'package:kampus_koin_app/features/home/widgets/user_badge.dart';
import 'package:kampus_koin_app/features/home/widgets/savings_chart.dart';
import 'package:intl/intl.dart';
import 'dart:ui';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    final goalsData = ref.watch(goalsProvider);
    final transactionsData = ref.watch(transactionsProvider);
    final totalSavings = ref.watch(totalSavingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final currencyFormatter = NumberFormat.currency(locale: 'en_KE', symbol: 'KES ');

    // 1. LISTEN FOR ERRORS
    ref.listen<GoalCreationState>(goalNotifierProvider, (prev, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    // 2. LISTEN FOR SCORE INCREASES (Unlock Logic)
    ref.listen(userDataProvider, (previous, next) {
      // Only proceed if we have both previous and next data
      if (previous?.hasValue == true && next.hasValue) {
        final oldScore = previous!.value!.koinScore;
        final newScore = next.value!.koinScore;

        // If score increased (e.g. after deposit or repayment)
        if (newScore > oldScore) {
          // Get the list of products (without triggering a rebuild)
          final products = ref.read(productsProvider).valueOrNull ?? [];

          for (var product in products) {
            // LOGIC: If I couldn't afford it before (oldScore < req)
            // BUT I can afford it now (newScore >= req)
            // AND I haven't already bought it...
            if (!product.isAlreadyUnlocked && 
                oldScore < product.requiredKoinScore && 
                newScore >= product.requiredKoinScore) {
              
              // Trigger the notification
              ref.read(notificationServiceProvider).showUnlockAlert(product.name);
            }
          }
        }
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Dashboard',
            style: TextStyle(fontWeight: FontWeight.w600, color: Colors.white)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.logout_rounded, color: Colors.white),
              onPressed: () {
                ref.read(authNotifierProvider.notifier).logout();
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        color: colorScheme.primary,
        backgroundColor: Colors.white,
        onRefresh: () async {
          // Use Future.wait to keep spinner visible until all load
          await Future.wait([
            ref.refresh(userDataProvider.future),
            ref.refresh(goalsProvider.future),
            ref.refresh(transactionsProvider.future),
            ref.refresh(productsProvider.future), // Refresh products too just in case
          ]);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ), 
          slivers: [
            SliverToBoxAdapter(
              child: userData.when(
                loading: () => const SizedBox(
                  height: 400,
                  child: Center(child: CircularProgressIndicator(color: Colors.white)),
                ),
                error: (err, stack) =>
                    Container(height: 200, child: Center(child: Text('Error loading user'))),
                data: (user) {
                  return Stack(
                    children: [
                      // 1. Gradient Background
                      Container(
                        height: 420,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary, 
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(40),
                            bottomRight: Radius.circular(40),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                      ),
                      
                      // 2. Decorative elements
                      Positioned(
                        top: -60,
                        right: -60,
                        child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.05)),
                      ),
                      Positioned(
                        top: 80,
                        left: -40,
                        child: CircleAvatar(radius: 70, backgroundColor: Colors.white.withOpacity(0.05)),
                      ),

                      // 3. Content
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 110, 24, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Greeting & Badge
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Welcome back,',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white.withOpacity(0.8),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      user.name.split(' ')[0], 
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                  ],
                                ),
                                UserBadge(koinScore: user.koinScore),
                              ],
                            ),
                            
                            const SizedBox(height: 24),

                            // Glassmorphic Stats Row
                            ClipRRect(
                              borderRadius: BorderRadius.circular(24),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: Container(
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                                  ),
                                  child: Row(
                                    children: [
                                      // Total Savings
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.account_balance_wallet_rounded, 
                                                  color: Colors.white.withOpacity(0.8), size: 16),
                                                const SizedBox(width: 8),
                                                Text('Total Savings', 
                                                  style: TextStyle(color: Colors.white.withOpacity(0.8))),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              currencyFormatter.format(totalSavings),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      // Divider
                                      Container(
                                        height: 40,
                                        width: 1,
                                        color: Colors.white.withOpacity(0.2),
                                      ),
                                      const SizedBox(width: 24),
                                      // Koin Score
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.stars_rounded, 
                                                  color: Colors.amberAccent, size: 16),
                                                const SizedBox(width: 8),
                                                Text('Koin Score', 
                                                  style: TextStyle(color: Colors.white.withOpacity(0.8))),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              user.koinScore.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 22,
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

                            // Chart
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                   BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))
                                ]
                              ),
                              padding: const EdgeInsets.all(16),
                              child: transactionsData.when(
                                data: (transactions) => SavingsChart(transactions: transactions),
                                loading: () => const SizedBox(height: 200, child: Center(child: CircularProgressIndicator())),
                                error: (_, __) => const SizedBox.shrink()
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            // Goals Header
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              sliver: SliverToBoxAdapter(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Savings Goals',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 20,
                        color: Colors.black87,
                      ),
                    ),
                     goalsData.when(
                        data: (goals) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text('${goals.length} Active', 
                            style: TextStyle(color: colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                        loading: () => const SizedBox.shrink(),
                        error: (_,__) => const SizedBox.shrink(),
                      )
                  ],
                ),
              ),
            ),

            // Goals List
            goalsData.when(
              loading: () => const SliverToBoxAdapter(child: Center(child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(),
              ))),
              error: (err, stack) => SliverToBoxAdapter(child: Text('Error: $err')),
              data: (goals) {
                if (goals.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Center(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Icon(Icons.savings_outlined, size: 60, color: Colors.grey[300]),
                          const SizedBox(height: 10),
                          Text("Start saving today!", style: TextStyle(color: Colors.grey[500])),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => GoalListItem(goal: goals[index]),
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

// --- NEW & IMPROVED GOAL CARD ---
class GoalListItem extends ConsumerWidget {
  final Goal goal;

  const GoalListItem({super.key, required this.goal});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'Ksh ',
      decimalDigits: 0,
    );
    final bool isComplete = goal.progress >= 1.0;
    final colorScheme = Theme.of(context).colorScheme;
    final progressPercentage = (goal.progress * 100).toInt();

    // Determine color based on progress (Psychological cues)
    Color statusColor = colorScheme.primary;
    if (goal.progress > 0.75) statusColor = Colors.orange; // Almost there!
    if (isComplete) statusColor = Colors.green;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF9E9E9E).withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Section: Icon, Title, Delete
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Category Icon Box
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isComplete 
                        ? Colors.green.withOpacity(0.1) 
                        : colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    isComplete ? Icons.emoji_events_rounded : Icons.savings_rounded,
                    color: isComplete ? Colors.green : colorScheme.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Texts
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: currencyFormatter.format(goal.currentAmount),
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            TextSpan(
                              text: ' / ${currencyFormatter.format(goal.targetAmount)}',
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Percentage Badge & Delete
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () => _confirmDelete(context, ref, goal),
                      child: Icon(Icons.more_horiz, color: Colors.grey[400]),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$progressPercentage%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),

          // Middle: Linear Progress Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: goal.progress,
                minHeight: 8,
                backgroundColor: Colors.grey[100],
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Bottom: Action Button (Full Width Bottom Radius)
          isComplete
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: const BorderRadius.vertical(
                      bottom: Radius.circular(24),
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      'Goal Completed! 🎉',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : InkWell(
                  onTap: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: Colors.transparent,
                      builder: (ctx) => Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                        ),
                        child: DepositForm(goalId: goal.id, goalName: goal.name),
                      ),
                    );
                    // Refresh data after modal closes
                    ref.invalidate(userDataProvider);
                    ref.invalidate(goalsProvider);
                    ref.invalidate(transactionsProvider);
                  },
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface, // Very light grey
                      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
                      border: Border(top: BorderSide(color: Colors.grey.shade100)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline, size: 18, color: colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Add Deposit',
                          style: TextStyle(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Goal goal) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Goal'),
        content: Text('Are you sure you want to remove "${goal.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(goalNotifierProvider.notifier).deleteGoal(goal.id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}