// lib/features/profile/providers/orders_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
import 'package:kampus_koin_app/core/models/order_model.dart';

final ordersProvider = FutureProvider<List<Order>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getOrders();
});
