import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kampus_koin_app/core/api/api_service.dart';
import 'package:kampus_koin_app/features/home/providers/goals_provider.dart'; 
import 'package:kampus_koin_app/features/home/providers/user_data_provider.dart';
import 'package:kampus_koin_app/features/profile/providers/orders_provider.dart';
import 'package:kampus_koin_app/features/profile/providers/transactions_provider.dart';

final paymentPollingProvider = Provider((ref) => PaymentPollingService(ref));

class PaymentPollingService {
  final Ref ref;

  PaymentPollingService(this.ref);

  /// Polls the server until the goal amount increases or timeout is reached.
  /// [goalId]: The ID of the goal being funded.
  /// [originalAmount]: The amount BEFORE the deposit started.
  Future<bool> waitForDepositConfirmation(int goalId, double originalAmount) async {
    final apiService = ref.read(apiServiceProvider);
    int attempts = 0;
    const maxAttempts = 20; // 20 attempts * 3 seconds = 60 seconds max wait

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 3)); // Wait 3 seconds
      
      try {
        // Fetch the specific goal to see if it updated
        final updatedGoal = await apiService.getGoalDetails(goalId);
        
        // Check if money has been added
        if (updatedGoal.currentAmount > originalAmount) {
          // SUCCESS! The callback hit the server.
          
          // Now, force a global refresh of the UI
          ref.invalidate(goalsProvider);        // Refresh Goals Card
          ref.invalidate(userDataProvider);     // Refresh Wallet Balance
          ref.invalidate(transactionsProvider); // Refresh History
          
          return true; 
        }
      } catch (e) {
        print("Polling error: $e");
        // Continue polling even if one request fails (e.g. network blip)
      }
      
      attempts++;
    }
    
    return false; // Timed out without confirmation
  }

  /// Polls the server until the order 'amountPaid' increases.
  Future<bool> waitForRepaymentConfirmation(int orderId, double originalPaidAmount) async {
    final apiService = ref.read(apiServiceProvider);
    int attempts = 0;
    const maxAttempts = 20; // 60 seconds max

    while (attempts < maxAttempts) {
      await Future.delayed(const Duration(seconds: 3));
      
      try {
        // FIX: Use getOrders() (List) instead of getOrderDetails() (Single).
        // The error "String is not subtype of int" suggests the single endpoint 
        // might be returning a List [{}], causing the parser to crash. 
        // Fetching the full list and filtering in Dart is safer here.
        final orders = await apiService.getOrders();
        
        // Find the specific order in the list
        final updatedOrder = orders.firstWhere(
          (o) => o.id == orderId,
          orElse: () => throw Exception("Order not found in list"),
        );
        
        // Check if amount paid has increased
        if (updatedOrder.amountPaid > originalPaidAmount) {
          // SUCCESS! 
          
          // Force UI refresh for repayment-related providers
          ref.invalidate(ordersProvider);       // Refresh "Financed Items" & Progress Bars
          ref.invalidate(userDataProvider);     // Refresh Koin Score (if tied to repayment)
          ref.invalidate(transactionsProvider); // Refresh Transaction History
          
          return true;
        }
      } catch (e) {
        print("Polling repayment error: $e");
      }
      attempts++;
    }
    return false;
  }
}