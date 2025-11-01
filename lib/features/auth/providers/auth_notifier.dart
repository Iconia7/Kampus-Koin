// lib/features/auth/providers/auth_notifier.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';

// Define possible authentication states
enum AuthStatus { initial, loading, authenticated, error }

// Define the state class
class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  // We might store user data here later

  AuthState({this.status = AuthStatus.initial, this.errorMessage});

  AuthState copyWith({AuthStatus? status, String? errorMessage}) {
    return AuthState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Create the Notifier class
class AuthNotifier extends StateNotifier<AuthState> {
  final ApiService _apiService;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthNotifier(this._apiService) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _apiService.login(email, password);
      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      if (accessToken != null && refreshToken != null) {
        // Securely store the tokens
        await _secureStorage.write(key: 'accessToken', value: accessToken);
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);
        state = state.copyWith(status: AuthStatus.authenticated);
      } else {
        throw Exception('Tokens not found in response');
      }
    } catch (e) {
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
      // 1. Create the user
      await _apiService.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        admno: admno,
      );

      // 2. Immediately log the new user in to get tokens
      await login(email, password);

      // The 'login' method will handle storing tokens
      // and setting the state to Authenticated.
    } catch (e) {
      // Pass the specific error message from the ApiService
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  // Add logout and register methods later
  Future<void> logout() async {
    await _secureStorage.deleteAll();
    state = AuthState(); // Reset to initial state
  }
}

// Create the Riverpod provider for the AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService);
});
