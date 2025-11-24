// lib/core/models/order_model.dart
import 'package:kampus_koin_app/core/models/product_model.dart';

class Order {
  final int id;
  final int? user;
  final Product product;
  final double totalAmount;
  final double downPayment;
  final double amountFinanced;
  final double amountPaid;
  final String status;
  final DateTime? orderDate;
  final String pickupQrCode;

  Order({
    required this.id,
    this.user,
    required this.product,
    required this.totalAmount,
    required this.downPayment,
    required this.amountFinanced,
    required this.amountPaid,
    required this.status,
    this.orderDate,
    required this.pickupQrCode
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      // 1. Handle ID as int safely
      id: int.tryParse(json['id'].toString()) ?? 0,
      
      // 2. Handle nullable user
      user: json['user'], 
      
      // 3. Parse nested product safely
      product: Product.fromJson(json['product']), 
      
      // 4. BULLETPROOF DOUBLE PARSING
      // We convert to String first (.toString()), then parse.
      // This handles input like 100 (int), 100.50 (double), or "100.50" (String)
      totalAmount: double.tryParse((json['total_amount'] ?? 0).toString()) ?? 0.0,
      downPayment: double.tryParse((json['down_payment'] ?? 0).toString()) ?? 0.0,
      amountFinanced: double.tryParse((json['amount_financed'] ?? 0).toString()) ?? 0.0,
      amountPaid: double.tryParse((json['amount_paid'] ?? 0).toString()) ?? 0.0,
      
      status: json['status'] ?? 'PENDING',
      
      orderDate: json['order_date'] != null 
          ? DateTime.parse(json['order_date']) 
          : null,
          
      pickupQrCode: (json['pickup_qr_code'] ?? '').toString(),
    );
  }
}