// lib/features/home/providers/goals_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
import 'package:kampus_koin_app/core/models/goal_model.dart';

final goalsProvider = FutureProvider<List<Goal>>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return apiService.getSavingsGoals();
});
