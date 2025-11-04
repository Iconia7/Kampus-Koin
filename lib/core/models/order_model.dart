// lib/core/models/order_model.dart

import 'package:kampus_koin_app/core/models/product_model.dart';

class Order {
  final int id;
  final int user;
  final Product product;
  final double totalAmount;
  final double downPayment;
  final double amountFinanced;
  final double amountPaid; // <-- FIELD ADDED
  final String status;
  final DateTime orderDate;
  final String pickupQrCode;

  Order({
    required this.id,
    required this.user,
    required this.product,
    required this.totalAmount,
    required this.downPayment,
    required this.amountFinanced,
    required this.amountPaid, // <-- FIELD ADDED
    required this.status,
    required this.orderDate,
    required this.pickupQrCode
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      user: json['user'],
      product: Product.fromJson(json['product']), // <-- NULL SAFETY
      totalAmount: double.parse(
        json['total_amount'] ?? '0.0',
      ), // <-- NULL SAFETY
      downPayment: double.parse(
        json['down_payment'] ?? '0.0',
      ), // <-- NULL SAFETY
      amountFinanced: double.parse(
        json['amount_financed'] ?? '0.0',
      ), // <-- NULL SAFETY
      amountPaid: double.parse(json['amount_paid'] ?? '0.0'), // <-- NULL SAFETY
      status: json['status'] ?? 'PENDING', // <-- NULL SAFETY
      orderDate: DateTime.parse(
        json['order_date'],
      ),
      pickupQrCode: json['pickup_qr_code'], // This one should always exist
    );
  }
}
