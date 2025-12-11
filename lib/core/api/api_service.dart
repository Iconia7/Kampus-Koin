// lib/core/api/api_service.dart

import 'dart:io'; // Import for File
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kampus_koin_app/core/models/order_model.dart';
import 'package:kampus_koin_app/core/models/product_model.dart';
import 'package:kampus_koin_app/core/models/transaction_model.dart';
import 'package:kampus_koin_app/core/models/user_model.dart';
import 'package:kampus_koin_app/core/models/goal_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Helpful for content types if needed

const String baseUrl =
    'https://backend-fj0v.onrender.com/api'; 

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

class ApiService {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  ApiService() : _dio = Dio(BaseOptions(baseUrl: baseUrl)) {

    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.path == '/token/' || 
              options.path == '/token/refresh/' || 
              options.path == '/users/register/') {
            return handler.next(options);
          }

          final token = await _secureStorage.read(key: 'accessToken');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (e, handler) async {
          if (e.response?.statusCode == 401) {
            print("Token expired. Attempting refresh...");
            final refreshToken = await _secureStorage.read(key: 'refreshToken');
            if (refreshToken == null) {
              handler.next(e);
              return;
            }

            try {
              final response = await _dio.post(
                '/token/refresh/',
                data: {'refresh': refreshToken},
              );

              if (response.statusCode == 200) {
                final newAccessToken = response.data['access'];
                await _secureStorage.write(key: 'accessToken', value: newAccessToken);
                e.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
                final retriedResponse = await _dio.fetch(e.requestOptions);
                return handler.resolve(retriedResponse);
              }
            } on DioException {
              print("Refresh token is invalid. Logging out.");
              await _secureStorage.deleteAll();
            }
          }
          return handler.next(e);
        },
      ),
    );
  }

  // --- METHODS ---

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/token/', 
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      print('Dio login error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('General login error: $e');
      rethrow;
    }
  }

  Future<void> deleteGoal(int goalId) async {
    try {
      await _dio.delete('/finance/goals/$goalId/');
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
        '/finance/repay/', 
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
      final response = await _dio.get('/finance/transactions/');
      final List<dynamic> data = response.data;
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
      return data.map((json) => Order.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Dio getOrders error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('General getOrders error: $e');
      rethrow;
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get('/users/me/');
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
      final List<dynamic> data = response.data;
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
        '/finance/goals/',
        data: {'name': name, 'target_amount': targetAmount},
      );
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
      final response = await _dio.get('/finance/products/');
      final List<dynamic> data = response.data;
      return data.map((json) => Product.fromJson(json)).toList();
    } on DioException catch (e) {
      print('Dio getProducts error: ${e.response?.data}');
      rethrow;
    } catch (e) {
      print('General getProducts error: $e');
      rethrow;
    }
  }

  Future<Order> unlockProduct(int productId, {List<int>? goalIds}) async {
    try {
      final response = await _dio.post(
        '/finance/orders/unlock/',
        data: {
          'product_id': productId,
          if (goalIds != null && goalIds.isNotEmpty) 'goal_ids': goalIds, 
        },
      );
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      print('Dio unlockProduct error: ${e.response?.data}');
      if (e.response?.data is Map && (e.response!.data as Map).containsKey('detail')) {
        throw Exception(e.response!.data['detail']);}
        throw Exception('Failed to unlock product. Please try again.');
    } catch (e) {
      print('General unlockProduct error: $e');
      throw Exception('An unknown error occurred.');
    }
  }

  Future<Goal> getGoalDetails(int goalId) async {
    try {
      final response = await _dio.get('/finance/goals/$goalId/');
      return Goal.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch goal details');
    }
  }

  Future<Order> getOrderDetails(int orderId) async {
    try {
      final response = await _dio.get('/finance/orders/$orderId/');
      return Order.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data['detail'] ?? 'Failed to fetch order details');
    }
  }

  Future<void> updateFcmToken(String token) async {
    try {
      await _dio.post(
        '/finance/users/fcm-token/', 
        data: {'fcm_token': token}
      );
    } on DioException catch (e) {
      throw e; 
    }
  }

  // UPDATE: Support File Upload with FormData
  Future<User> updateProfile({String? name, String? phoneNumber, File? profileImage}) async {
    try {
      // 1. Create FormData
      final formData = FormData.fromMap({
        if (name != null && name.isNotEmpty) 'name': name,
        if (phoneNumber != null && phoneNumber.isNotEmpty) 'phone_number': phoneNumber,
        // Add file if present
        if (profileImage != null) 
          'profile_picture': await MultipartFile.fromFile(
            profileImage.path,
            filename: profileImage.path.split('/').last,
          ),
      });

      // 2. Send PATCH request with FormData
      final response = await _dio.patch(
        '/users/me/',
        data: formData,
        // Dio automatically sets 'Content-Type: multipart/form-data' when FormData is used
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
      final response = await _dio.post(
        '/finance/deposit/',
        data: {'goal_id': goalId, 'amount': amount},
      );

      if (response.data['message'] !=
          'STK push initiated successfully. Please enter your PIN.') {
        throw Exception('Failed to initiate STK push.');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['error'] ?? 'Failed to start deposit.');
    } catch (e) {
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
        '/users/register/', 
        data: {
          'name': name,
          'email': email,
          'password': password,
          'phone_number': phoneNumber,
          'student_id': admno,
        },
      );
      return User.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.data is Map) {
        final errors = e.response!.data as Map;
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
}