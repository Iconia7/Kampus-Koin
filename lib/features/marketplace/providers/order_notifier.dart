// lib/features/marketplace/providers/order_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
import 'package:kampus_koin_app/core/models/order_model.dart';
import 'package:kampus_koin_app/features/home/providers/user_data_provider.dart';
import 'package:kampus_koin_app/features/marketplace/providers/products_provider.dart';
import 'package:kampus_koin_app/features/profile/providers/orders_provider.dart';

// State for the order creation process
class OrderState {
  final bool isLoading;
  final String? errorMessage;
  final Order? createdOrder;
  OrderState({this.isLoading = false, this.errorMessage,this.createdOrder,});
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

  Future<Order?> unlockProduct(int productId) async {
    state = { ...state, productId: OrderState(isLoading: true) };
    try {
      final newOrder = await _apiService.unlockProduct(productId);
      
      state = {
        ...state,
        productId: OrderState(isLoading: false, createdOrder: newOrder) // <-- SET THE ORDER
      };
      
      // Refresh data
      _ref.invalidate(productsProvider);
      _ref.invalidate(userDataProvider);
      _ref.invalidate(ordersProvider); // Invalidate profile orders too
      
      return newOrder; // <-- RETURN THE ORDER
      
    } catch (e) {
      state = {
        ...state,
        productId: OrderState(isLoading: false, errorMessage: e.toString())
      };
      return null; // <-- Return null on failure
    }
  }

  // --- ADD A METHOD TO CLEAR THE STATE ---
  void clearOrderState(int productId) {
    state = {
      ...state,
      productId: OrderState() // Reset to initial
    };
  }
}
