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

  Future<void> checkAuthStatus() async {
    // Check secure storage for a token
    final token = await _secureStorage.read(key: 'accessToken');
    if (token != null) {
      // If we have a token, we are (at least initially) authenticated
      state = state.copyWith(status: AuthStatus.authenticated);
    } else {
      // No token, we are logged out
      state = state.copyWith(status: AuthStatus.initial);
    }
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      final response = await _apiService.login(email, password);
      final accessToken = response['access'];
      final refreshToken = response['refresh'];

      if (accessToken != null && refreshToken != null) {
        // 1. Securely store the tokens
        await _secureStorage.write(key: 'accessToken', value: accessToken);
        await _secureStorage.write(key: 'refreshToken', value: refreshToken);
        
        // 2. --- NEW: Save credentials for Biometrics ---
        await _secureStorage.write(key: 'bio_email', value: email);
        await _secureStorage.write(key: 'bio_password', value: password);
        // -----------------------------------------------

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
    String? admno, // Updated to match RegisterScreen
  }) async {
    state = state.copyWith(status: AuthStatus.loading, errorMessage: null);
    try {
      // 1. Create the user
      // Note: We map 'studentId' to the 'admno' parameter expected by ApiService
      await _apiService.register(
        name: name,
        email: email,
        password: password,
        phoneNumber: phoneNumber,
        admno: admno, 
      ); 

      // 2. Immediately log the new user in to get tokens
      // This will also save the bio credentials automatically via the login method above
      await login(email, password);

    } catch (e) {
      // Pass the specific error message from the ApiService
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> logout() async {
    // We delete everything, including biometric data, for security on logout.
    await _secureStorage.deleteAll();
    state = AuthState(); // Reset to initial state
  }
}

// Create the Riverpod provider for the AuthNotifier
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
  final apiService = ref.watch(apiServiceProvider);
  return AuthNotifier(apiService)..checkAuthStatus();
});