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

final orderNotifierProvider =
    StateNotifierProvider<OrderNotifier, Map<int, OrderState>>((ref) {
      final apiService = ref.watch(apiServiceProvider);
      return OrderNotifier(apiService, ref);
    });

class OrderNotifier extends StateNotifier<Map<int, OrderState>> {
  final ApiService _apiService;
  final Ref _ref;

  OrderNotifier(this._apiService, this._ref) : super({});

  // UPDATE: Accepts list of IDs now
  Future<Order?> unlockProduct(int productId, {List<int>? goalIds}) async {
    state = { ...state, productId: OrderState(isLoading: true) };
    try {
      // Pass list to API
      final newOrder = await _apiService.unlockProduct(productId, goalIds: goalIds);
      
      state = {
        ...state,
        productId: OrderState(isLoading: false, createdOrder: newOrder)
      };
      
      _ref.invalidate(productsProvider);
      _ref.invalidate(userDataProvider);
      _ref.invalidate(ordersProvider); 
      
      return newOrder; 
      
    } catch (e) {
      state = {
        ...state,
        productId: OrderState(isLoading: false, errorMessage: e.toString())
      };
      return null;
    }
  }

  void clearOrderState(int productId) {
    state = {
      ...state,
      productId: OrderState() 
    };
  }
}