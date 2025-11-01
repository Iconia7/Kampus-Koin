// lib/core/models/user_model.dart

class User {
  final int id;
  final String email;
  final String name;
  final String? admno; // Make fields nullable if they can be null in the API
  final String? phoneNumber;
  final int koinScore;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.admno,
    this.phoneNumber,
    required this.koinScore,
  });

  // Factory constructor to create a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      admno: json['student_no'], // Map API snake_case to Dart camelCase
      phoneNumber: json['phone_number'],
      koinScore: json['koin_score'],
    );
  }
}
