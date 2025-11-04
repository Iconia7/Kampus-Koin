// lib/features/home/providers/total_savings_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/features/home/providers/goals_provider.dart';

final totalSavingsProvider = Provider<double>((ref) {
  // Watch the main goalsProvider
  final goalsAsyncValue = ref.watch(goalsProvider);
  
  // When it has data, calculate the total. Otherwise, return 0.
  return goalsAsyncValue.when(
    data: (goals) {
      if (goals.isEmpty) {
        return 0.0;
      }
      // Use fold to sum the currentAmount of all goals
      return goals.fold(0.0, (sum, goal) => sum + goal.currentAmount);
    },
    loading: () => 0.0,
    error: (e, s) => 0.0,
  );
});