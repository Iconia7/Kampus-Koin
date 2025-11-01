// lib/core/models/order_model.dart

class Order {
  final int id;
  final int user;
  final String product;
  final double totalAmount;
  final double downPayment;
  final double amountFinanced;
  final double amountPaid; // <-- FIELD ADDED
  final String status;
  final DateTime orderDate;

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
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      user: json['user'],
      product: json['product'] ?? 'Unknown Product', // <-- NULL SAFETY
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
      ), // This one should always exist
    );
  }
}
