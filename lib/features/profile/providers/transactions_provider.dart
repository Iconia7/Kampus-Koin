// lib/features/profile/providers/transactions_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
import 'package:kampus_koin_app/core/models/transaction_model.dart';

final transactionsProvider = FutureProvider<List<Transaction>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getTransactions();
});
