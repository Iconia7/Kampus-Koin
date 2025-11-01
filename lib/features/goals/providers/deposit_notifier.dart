// lib/features/goals/providers/deposit_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';

// Simple state class
class DepositState {
  final bool isLoading;
  final String? errorMessage;
  DepositState({this.isLoading = false, this.errorMessage});
}

// Notifier class
class DepositNotifier extends StateNotifier<DepositState> {
  final ApiService _apiService;
  final Ref ref;

  DepositNotifier(this._apiService, this.ref) : super(DepositState());

  Future<bool> depositToGoal(int goalId, String amount) async {
    state = DepositState(isLoading: true);
    try {
      await _apiService.depositToGoal(goalId, amount);
      state = DepositState(isLoading: false);
      return true; // Success
    } catch (e) {
      state = DepositState(isLoading: false, errorMessage: e.toString());
      return false; // Failure
    }
  }
}

// The provider
final depositNotifierProvider =
    StateNotifierProvider<DepositNotifier, DepositState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return DepositNotifier(apiService, ref);
    });
