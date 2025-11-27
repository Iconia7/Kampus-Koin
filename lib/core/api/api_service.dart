// lib/core/api/api_service.dart

import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kampus_koin_app/core/models/order_model.dart';
import 'package:kampus_koin_app/core/models/product_model.dart';
import 'package:kampus_koin_app/core/models/transaction_model.dart';
import 'package:kampus_koin_app/core/models/user_model.dart';
import 'package:kampus_koin_app/core/models/goal_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
const String baseUrl =
    'https://backend-fj0v.onrender.com/api'; // 10.0.2.2 is the special IP for Android emulator to reach localhost

// Create a Riverpod provider for easy access to the ApiService
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(

        // --- 1. ATTACH TOKEN TO (ALMOST) EVERY REQUEST ---
        onRequest: (options, handler) async {
          // Public routes that don't need a token
          if (options.path == '/token/' || 
              options.path == '/token/refresh/' || 
              options.path == '/users/register/') {
            return handler.next(options); // Continue without a token
          }

          final token = await _secureStorage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        // --- 2. HANDLE TOKEN EXPIRY (401 ERROR) ---
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            print("Token expired. Attempting refresh...");

            // Get the old refresh token
            final refreshToken = await _secureStorage.read(key: 'refreshToken');
            if (refreshToken == null) {
              // If we have no refresh token, log out
              handler.next(e);
              // We should also tell the authNotifier to log out
              return;
            }

            try {
              // --- 3. REQUEST NEW TOKENS ---
              final response = await _dio.post(
                '/token/refresh/',
                data: {'refresh': refreshToken},
              );

              if (response.statusCode == 200) {
                // Successfully got new tokens
                final newAccessToken = response.data['access'];

                // Save new token
                await _secureStorage.write(key: 'accessToken', value: newAccessToken);

                // --- 4. RETRY THE ORIGINAL, FAILED REQUEST ---
                // Update the request header with the new token
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

                // Re-send the original request
                final retriedResponse = await _dio.fetch(e.requestOptions);
                return handler.resolve(retriedResponse);
              }
            } on DioException {
              // If the refresh token is also invalid, we must log out
              print("Refresh token is invalid. Logging out.");
              await _secureStorage.deleteAll();
              // We should tell the authNotifier to log out
              // This is tricky from here, the router's redirect will handle it
            }
          }
          return handler.next(e); // Pass on other errors
        },
      ),
    );
  }
  // --- AUTH METHODS ---

  // Method to handle user login
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/token/', // Endpoint for getting JWT tokens
        data: {'email': email, 'password': password},
      );
      // Assuming the response body contains 'access' and 'refresh' tokens
      return response.data;
    } on DioException catch (e) {
      // Handle API errors (like 400 Bad Request, 500 Server Error)
      print('Dio login error: ${e.response?.data}');
      rethrow; // Rethrow to let the calling code handle UI feedback
    } catch (e) {
      // Handle other errors (like network issues)
      print('General login error: $e');
      rethrow;
    }
  }

  Future<void> deleteGoal(int goalId) async {
    try {
      // Our interceptor will handle the auth token
      await _dio.delete('/finance/goals/$goalId/');
      // A successful 204 No Content response won't return data
    } on DioException catch (e) {
      print('Dio deleteGoal error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('General deleteGoal error: $e');
      rethrow;
    }
  }

  Future<void> repayOrder(int orderId, String amount) async {
    try {
      final response = await _dio.post(
        '/finance/repay/', // The new endpoint we created in Django
        data: {'order_id': orderId, 'amount': amount},
      );

      if (response.data['message'] !=
          'Repayment STK push initiated. Please enter your PIN.') {
        throw Exception('Failed to initiate STK push.');
      }
    } on DioException catch (e) {
      print('Dio repayOrder error: ${e.response?.data}');
      throw Exception(
        e.response?.data['error'] ?? 'Failed to start repayment.',
      );
    } catch (e) {
      print('General repayOrder error: $e');
      rethrow;
    }
  }

  Future<List<Transaction>> getTransactions() async {
    try {
      // Our interceptor handles the auth token
      final response = await _dio.get('/finance/transactions/');
      final List<dynamic> data = response.data;

      // Map the list of JSON objects to a List<Transaction>
      return data.map((json) => Transaction.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Dio getTransactions error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('General getTransactions error: $e');
      rethrow;
    }
  }

  Future<List<Order>> getOrders() async {
    try {
      final response = await _dio.get('/finance/orders/');
      final List<dynamic> data = response.data;

      // Map the list of JSON objects to a List<Order>
      return data.map((json) => Order.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Dio getOrders error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('General getOrders error: $e');
      rethrow;
    }
  }

  // Method to get the current user's profile (We'll implement this later)
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me/');
      // The interceptor automatically added the token for us!

      // Deserialize the JSON response into our User model
      return User.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio getCurrentUser error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('General getCurrentUser error: $e');
      rethrow;
    }
  }

  Future<List<Goal>> getSavingsGoals() async {
    try {
      final response = await _dio.get('/finance/goals/');
      print('DEBUG: Goals response: ${response.data}');
      // The response.data is a List of JSON objects
      final List<dynamic> data = response.data;

      // Map the list of JSON objects to a List<Goal>
      return data.map((json) => Goal.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Dio getSavingsGoals error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('General getSavingsGoals error: $e');
      rethrow;
    }
  }

  Future<Goal> createGoal(String name, String targetAmount) async {
    try {
      final response = await _dio.post(
        '/finance/goals/', // Our ListCreate endpoint
        data: {'name': name, 'target_amount': targetAmount},
      );
      // Return the new goal from the response
      return Goal.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio createGoal error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('General createGoal error: $e');
      rethrow;
    }
  }

  Future<List<Product>> getProducts() async {
    try {
      // This endpoint is protected, but our interceptor handles the token
      final response = await _dio.get('/finance/products/');
      final List<dynamic> data = response.data;

      // Map the list of JSON objects to a List<Product>
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Dio getProducts error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('General getProducts error: $e');
      rethrow;
    }
  }

  Future<Order> unlockProduct(int productId) async {
    try {
      final response = await _dio.post(
        '/finance/orders/unlock/',
        data: {'product_id': productId},
      );
      // The interceptor handles the auth token
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio unlockProduct error: ${e.response?.data}');
      // --- THIS IS THE FIX ---
      // Safely check if the response data is a Map and contains the key
      if (e.response?.data is Map && (e.response!.data as Map).containsKey('detail')) {
        // If it's a 400 with a "detail" key (like "Koin score too low")
        throw Exception(e.response!.data['detail']);}
        throw Exception('Failed to unlock product. Please try again.');
    } catch (e) {
      print('General unlockProduct error: $e');
      throw Exception('An unknown error occurred.');
    }
  }

  Future<User> updateProfile({String? name, String? phoneNumber}) async {
    try {
      final response = await _dio.patch(
        '/users/me/',
        data: {
          if (name != null) 'name': name,
          if (phoneNumber != null) 'phone_number': phoneNumber,
        },
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio updateProfile error: ${e.response?.data}');
      throw Exception(e.response?.data['detail'] ?? 'Failed to update profile');
    } catch (e) {
      print('General updateProfile error: $e');
      rethrow;
    }
  }

  Future<void> depositToGoal(int goalId, String amount) async {
    try {
      // Our interceptor will handle the auth token
      final response = await _dio.post(
        '/finance/deposit/',
        data: {'goal_id': goalId, 'amount': amount},
      );

      // Check for M-Pesa's success response
      if (response.data['message'] !=
          'STK push initiated successfully. Please enter your PIN.') {
        // If the backend returned an error (e.g., M-Pesa is down)
        throw Exception('Failed to initiate STK push.');
      }
      // If successful, the backend returns a 200 OK
      // The actual database update happens via the callback.
    } on DioException catch (e) {
      print('Dio depositToGoal error: ${e.response?.data}');
      throw Exception(e.response?.data['error'] ?? 'Failed to start deposit.');
    } catch (e) {
      print('General depositToGoal error: $e');
      rethrow;
    }
  }

  Future<User> register({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
    String? admno,
  }) async {
    try {
      final response = await _dio.post(
        '/users/register/', // Your Django registration endpoint
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'student_id': admno,
        },
      );
      // If successful, Django returns the new User object
      return User.fromJson(response.data);
    } on DioException catch (e) {
      // Handle errors from Django (like "email already in use")
      if (e.response?.data is Map) {
        final errors = e.response!.data as Map;
        // Find the first error and throw it
        if (errors.containsKey('email')) {
          throw Exception(errors['email'][0].toString());
        }
        if (errors.containsKey('phone_number')) {
          throw Exception(errors['phone_number'][0].toString());
        }
      }
      throw Exception('Registration failed. Please check your details.');
    } catch (e) {
      throw Exception('An unknown error occurred.');
    }
  }

  // --- Add methods for Goals, Products, Orders later ---
}
