// lib/core/models/product_model.dart
import 'package:kampus_koin_app/core/models/order_model.dart';

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int requiredKoinScore;
  final bool isUnlocked;
  final bool isAlreadyUnlocked;
  final String? vendorName;
  final String? vendorLocation;
  final Order? activeOrder;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.requiredKoinScore,
    required this.isUnlocked,
    required this.isAlreadyUnlocked,
    this.vendorName,
    this.vendorLocation,
    this.activeOrder,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      // Safely parse ID
      id: int.tryParse(json['id'].toString()) ?? 0,
      
      name: json['name'] ?? 'Unknown',
      description: json['description'] ?? '',
      
      // BULLETPROOF DOUBLE PARSING
      price: double.tryParse((json['price'] ?? 0).toString()) ?? 0.0,
      
      // BULLETPROOF INT PARSING
      requiredKoinScore: int.tryParse((json['required_koin_score'] ?? 0).toString()) ?? 0,
      
      isUnlocked: json['is_unlocked'] ?? false,
      isAlreadyUnlocked: json['is_already_unlocked'] ?? false,
      vendorName: json['vendor_name'],
      vendorLocation: json['vendor_location'],
      
      activeOrder: json['active_order'] != null 
          ? Order.fromJson(json['active_order']) 
          : null,
    );
  }
}