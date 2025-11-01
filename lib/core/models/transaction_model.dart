// lib/core/models/transaction_model.dart

class Transaction {
  final int id;
  final int? goal;
  final int? order; // <-- FIELD ADDED
  final String transactionType; // <-- FIELD ADDED
  final double? amount;
  final String? mpesaReceiptNumber;
  final DateTime? transactionDate;
  final String status;

  Transaction({
    required this.id,
    this.goal,
    this.order, // <-- FIELD ADDED
    required this.transactionType, // <-- FIELD ADDED
    this.amount,
    this.mpesaReceiptNumber,
    this.transactionDate,
    required this.status,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      goal: json['goal'],
      order: json['order'], // <-- FIELD ADDED
      transactionType:
          json['transaction_type'] ??
          'DEPOSIT', // <-- FIELD ADDED + NULL SAFETY
      amount: json['amount'] != null ? double.parse(json['amount']) : null,
      mpesaReceiptNumber: json['mpesa_receipt_number'],
      transactionDate: json['transaction_date'] != null
          ? DateTime.parse(json['transaction_date'])
          : null,
      status: json['status'] ?? 'pending', // <-- NULL SAFETY
    );
  }
}
