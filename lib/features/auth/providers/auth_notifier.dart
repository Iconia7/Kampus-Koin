// lib/features/auth/providers/auth_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
import 'package:kampus_koin_app/core/services/notification_service.dart';

enum AuthStatus { initial, loading, authenticated, error }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  AuthState({this.status = AuthStatus.initial, this.errorMessage});

  AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  // 1. Add NotificationService as a dependency
  final NotificationService _notificationService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  // 2. Update Constructor to accept it
  AuthNotifier(this._apiService, this._notificationService) : super(AuthState());

  Future<void> checkAuthStatus() async {
    final token = await _secureStorage.read(key: 'accessToken');
    if (token != null) {
      state = state.copyWith(status: AuthStatus.authenticated);
      // Optional: Sync token on app start/refresh if needed
      // _notificationService.syncTokenWithServer(_apiService);
    } else {
      state = state.copyWith(status: AuthStatus.initial);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      print("DEBUG: Logging in with $email...");

      final response = await _apiService.login(email, password);
      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      if (accessToken != null && refreshToken != null) {
        // Save Tokens
        await _secureStorage.write(key: 'accessToken', value: accessToken);
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);
        
        // Save Credentials for Biometrics
        print("DEBUG: Saving credentials for biometrics...");
        await _secureStorage.write(key: 'bio_email', value: email);
        await _secureStorage.write(key: 'bio_password', value: password);
        print("DEBUG: Credentials saved!");

        state = state.copyWith(status: AuthStatus.authenticated);

        // 3. --- FIX: Use the injected service (No 'ref' needed here) ---
        // This ensures the backend gets the FCM token immediately
        await _notificationService.syncTokenWithServer(_apiService);
        
      } else {
        throw Exception('Tokens not found in response');
      }
    } catch (e) {
      print("DEBUG: Login Error: $e");
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login failed. Please check your credentials.',
      );
    }
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String? admno,
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      await _apiService.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        admno: admno, 
      );
      // Login immediately to save credentials
      await login(email, password);
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    // Keeping bio credentials for quick login
    state = AuthState(); 
  }
}

// 4. --- FIX: Update the Provider Definition ---
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  // Get the notification service from its provider
  final notificationService = ref.watch(notificationServiceProvider);
  
  // Inject both into the Notifier
  return AuthNotifier(apiService, notificationService)..checkAuthStatus();
});