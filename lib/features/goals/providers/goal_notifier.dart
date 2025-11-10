// lib/features/goals/providers/goal_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
import 'package:kampus_koin_app/features/home/providers/goals_provider.dart';
import 'package:kampus_koin_app/features/home/providers/total_savings_provider.dart';

// Simple state class for this notifier
class GoalCreationState {
  final bool isLoading;
  final String? errorMessage;
  GoalCreationState({this.isLoading = false, this.errorMessage});
}

// Notifier class
class GoalNotifier extends StateNotifier<GoalCreationState> {
  final ApiService _apiService;
  final Ref _ref; // We need Ref to talk to other providers

  GoalNotifier(this._apiService, this._ref) : super(GoalCreationState());

  Future<bool> createGoal(String name, String targetAmount) async {
    state = GoalCreationState(isLoading: true);
    try {
      await _apiService.createGoal(name, targetAmount);
      state = GoalCreationState(isLoading: false);

      // --- CRITICAL STEP ---
      // Invalidate the goalsProvider to force it to refetch
      _ref.invalidate(goalsProvider);

      return true; // Return success
    } catch (e) {
      state = GoalCreationState(
        isLoading: false,
        errorMessage: "Failed to create goal.",
      );
      return false; // Return failure
    }
  }
  Future<bool> deleteGoal(int goalId) async {
    // We can use the same state to show a global loading/error
    state = GoalCreationState(isLoading: true);
    try {
      await _apiService.deleteGoal(goalId);
      
      // --- CRITICAL STEP ---
      // Refresh both the goals list and the total savings
      _ref.invalidate(goalsProvider);
      _ref.invalidate(totalSavingsProvider);
      
      state = GoalCreationState(isLoading: false); // Reset state
      return true; // Return success
    } catch (e) {
      state = GoalCreationState(isLoading: false, errorMessage: "Failed to delete goal.");
      return false; // Return failure
    }
  }
}

// The provider for our new notifier
final goalNotifierProvider =
    StateNotifierProvider<GoalNotifier, GoalCreationState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return GoalNotifier(apiService, ref);
    });
