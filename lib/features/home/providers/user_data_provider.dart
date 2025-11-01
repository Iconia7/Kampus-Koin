// lib/features/home/providers/user_data_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
import 'package:kampus_koin_app/core/models/user_model.dart';

final userDataProvider = FutureProvider<User>((ref) async {
  // Get the ApiService from its provider
  final apiService = ref.watch(apiServiceProvider);
  // Fetch the user data
  return apiService.getCurrentUser();
});
