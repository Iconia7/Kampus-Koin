// lib/features/auth/providers/auth_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';

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
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthNotifier(this._apiService) : super(AuthState());

  Future<void> checkAuthStatus() async {
    final token = await _secureStorage.read(key: 'accessToken');
    if (token != null) {
      state = state.copyWith(status: AuthStatus.authenticated);
    } else {
      state = state.copyWith(status: AuthStatus.initial);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      print("DEBUG: Logging in with $email..."); // Debug log

      final response = await _apiService.login(email, password);
      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      if (accessToken != null && refreshToken != null) {
        // 1. Save Tokens
        await _secureStorage.write(key: 'accessToken', value: accessToken);
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);
        
        // 2. --- CRITICAL: Save Credentials for Biometrics ---
        print("DEBUG: Saving credentials for biometrics..."); // Debug log
        await _secureStorage.write(key: 'bio_email', value: email);
        await _secureStorage.write(key: 'bio_password', value: password);
        print("DEBUG: Credentials saved!"); // Debug log
        // ---------------------------------------------------

        state = state.copyWith(status: AuthStatus.authenticated);
      } else {
        throw Exception('Tokens not found in response');
      }
    } catch (e) {
      print("DEBUG: Login Error: $e"); // Debug log
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
    // Note: In a real app, you might want to keep bio_email/bio_password 
    // even after logout so they can quick-login again. 
    // For now, we delete tokens but keep bio data is a common pattern, 
    // BUT for this specific implementation, let's just delete tokens.
    
    await _secureStorage.delete(key: 'accessToken');
    await _secureStorage.delete(key: 'refreshToken');
    // We DO NOT delete bio_email/bio_password here, otherwise 
    // the fingerprint button will disappear every time you logout!
    
    state = AuthState(); 
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService)..checkAuthStatus();
});