// lib/core/models/product_model.dart

class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final int requiredKoinScore;
  final bool isUnlocked;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.requiredKoinScore,
    required this.isUnlocked,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      // Django's DecimalField is a string, so we must parse it.
      price: double.parse(json['price']),
      requiredKoinScore: json['required_koin_score'],
      isUnlocked: json['is_unlocked'],
    );
  }
}
