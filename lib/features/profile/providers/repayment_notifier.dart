// lib/features/profile/providers/repayment_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
// We don't need these imports anymore since we aren't invalidating
// import 'package:kampus_koin_app/features/home/providers/user_data_provider.dart';
// import 'package:kampus_koin_app/features/profile/providers/orders_provider.dart';
// import 'package:kampus_koin_app/features/profile/providers/transactions_provider.dart';

// Simple state class
class RepaymentState {
  final bool isLoading;
  final String? errorMessage;
  RepaymentState({this.isLoading = false, this.errorMessage});
}

// Notifier class
class RepaymentNotifier extends StateNotifier<RepaymentState> {
  final ApiService _apiService;
  final Ref ref;

  RepaymentNotifier(this._apiService, this.ref) : super(RepaymentState());

  Future<bool> repayOrder(int orderId, String amount) async {
    state = RepaymentState(isLoading: true);
    try {
      await _apiService.repayOrder(orderId, amount);
      state = RepaymentState(isLoading: false);

      // --- THIS IS THE FIX ---
      // We do NOT invalidate here. We let the user
      // pull-to-refresh after they get the M-Pesa SMS.

      // _ref.invalidate(transactionsProvider);
      // _ref.invalidate(ordersProvider);
      // _ref.invalidate(userDataProvider);

      return true; // Success
    } catch (e) {
      state = RepaymentState(isLoading: false, errorMessage: e.toString());
      return false; // Failure
    }
  }
}

// The provider
final repaymentNotifierProvider =
    StateNotifierProvider<RepaymentNotifier, RepaymentState>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return RepaymentNotifier(apiService, ref);
    });
