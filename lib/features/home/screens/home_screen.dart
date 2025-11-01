// lib/features/home/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/models/goal_model.dart';
import 'package:kampus_koin_app/features/goals/widgets/deposit_form.dart';
import 'package:kampus_koin_app/features/home/providers/user_data_provider.dart';
import '../../auth/providers/auth_notifier.dart';
import 'package:kampus_koin_app/features/home/providers/goals_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = ref.watch(userDataProvider);
    final goalsData = ref.watch(goalsProvider); // Watch the goals provider
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: colorScheme.primary),
            onPressed: () {
              ref.read(authNotifierProvider.notifier).logout();
            },
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: () async {
          // This will re-run both FutureProviders
          ref.invalidate(userDataProvider);
          ref.invalidate(goalsProvider);
        },
        // We use a CustomScrollView to combine scrolling content
        // with the RefreshIndicator
        child: CustomScrollView(
          // This makes the refresh work even if content is small
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // We use SliverToBoxAdapter to hold our non-list content
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
                  return Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Welcome Header
                        Text(
                          'Welcome back,',
                          style: textTheme.bodyLarge?.copyWith(fontSize: 20),
                        ),
                        Text(
                          user.name,
                          style: textTheme.displayLarge?.copyWith(
                            color: colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Koin Score Card
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withOpacity(0.3),
                                blurRadius: 15,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'YOUR KOIN SCORE',
                                style: textTheme.bodyMedium?.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                user.koinScore.toString(),
                                style: textTheme.displayLarge?.copyWith(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 32),

                        Text(
                          'My Savings Goals',
                          style: textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  );
                },
              ),
            ),

            // This is the list of goals
            goalsData.when(
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (err, stack) => SliverToBoxAdapter(
                child: Center(child: Text('Could not load goals: $err')),
              ),
              data: (goals) {
                if (goals.isEmpty) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(32.0),
                        child: Text("You haven't created any goals yet."),
                      ),
                    ),
                  );
                }
                // This is a scrolling list that is built efficiently
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final goal = goals[index];
                      return GoalListItem(goal: goal);
                    }, childCount: goals.length),
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

// --- UPDATED WIDGET: GoalListItem ---
class GoalListItem extends StatelessWidget {
  final Goal goal;

  const GoalListItem({super.key, required this.goal});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_KE',
      symbol: 'Ksh ',
    );

    // --- THIS IS THE NEW LOGIC ---
    final bool isComplete = goal.progress >= 1.0;
    final colorScheme = Theme.of(context).colorScheme;
    // ----------------------------

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            goal.name,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(fontSize: 18),
          ),
          const SizedBox(height: 12),
          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: goal.progress,
              minHeight: 10,
              backgroundColor: colorScheme.background,
              // --- UPDATE COLOR BASED ON COMPLETION ---
              valueColor: AlwaysStoppedAnimation<Color>(
                isComplete ? Colors.green : colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Progress Text
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                currencyFormatter.format(goal.currentAmount),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  // --- UPDATE COLOR BASED ON COMPLETION ---
                  color: isComplete ? Colors.green : colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'of ${currencyFormatter.format(goal.targetAmount)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- THIS IS THE UPDATED WIDGET ---
          SizedBox(
            width: double.infinity,
            // Conditionally show the correct button
            child: isComplete
                ? ElevatedButton.icon(
                    // Show a "Goal Complete" button
                    icon: const Icon(Icons.check_circle),
                    label: const Text('Goal Complete! 🎉'),
                    onPressed: null, // This disables the button
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      disabledBackgroundColor: Colors.green.withOpacity(0.8),
                      disabledForegroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                : OutlinedButton.icon(
                    // Show the "Deposit" button
                    icon: const Icon(Icons.add),
                    label: const Text('Deposit Money'),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                        ),
                        builder: (ctx) =>
                            DepositForm(goalId: goal.id, goalName: goal.name),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: colorScheme.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
          ),
          // ---------------------------------
        ],
      ),
    );
  }
}
