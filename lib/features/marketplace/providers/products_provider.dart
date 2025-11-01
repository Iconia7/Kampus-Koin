// lib/features/marketplace/providers/products_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
import 'package:kampus_koin_app/core/models/product_model.dart';

final productsProvider = FutureProvider<List<Product>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getProducts();
});
