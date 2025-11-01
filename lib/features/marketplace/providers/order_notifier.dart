// lib/features/marketplace/providers/order_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
import 'package:kampus_koin_app/features/home/providers/user_data_provider.dart';
import 'package:kampus_koin_app/features/marketplace/providers/products_provider.dart';

// State for the order creation process
class OrderState {
  final bool isLoading;
  final String? errorMessage;
  OrderState({this.isLoading = false, this.errorMessage});
}

// We use StateNotifierProvider because we'll have multiple loading states
// We key it by product ID (int) to only show loading on the card we clicked
final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, Map<int, OrderState>>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return OrderNotifier(apiService, ref);
    });

class OrderNotifier extends StateNotifier<Map<int, OrderState>> {
  final ApiService _apiService;
  final Ref _ref;

  OrderNotifier(this._apiService, this._ref) : super({});

  Future<bool> unlockProduct(int productId) async {
    // Set loading state for this specific product
    state = {...state, productId: OrderState(isLoading: true)};

    try {
      await _apiService.unlockProduct(productId);

      // Clear loading state on success
      state = {...state, productId: OrderState(isLoading: false)};

      // --- REFRESH DATA ---
      // 1. Refresh the product list (isUnlocked might change)
      _ref.invalidate(productsProvider);
      // 2. Refresh the user's data (Koin Score might change)
      _ref.invalidate(userDataProvider);

      return true; // Success
    } catch (e) {
      // Set error state for this product
      state = {
        ...state,
        productId: OrderState(isLoading: false, errorMessage: e.toString()),
      };
      return false; // Failure
    }
  }
}
