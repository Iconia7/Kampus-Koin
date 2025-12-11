// lib/core/models/user_model.dart

class User {
  final int id;
  final String email;
  final String name;
  final String? admno; // Make fields nullable if they can be null in the API
  final String? phoneNumber;
  final int koinScore;
  final String? profilePicture;

  User({
    required this.id,
    required this.email,
    required this.name,
    this.admno,
    this.phoneNumber,
    required this.koinScore,
    this.profilePicture,
  });

  // Factory constructor to create a User from JSON data
  factory User.fromJson(Map<String, dynamic> json) {
    String? getValidProfileUrl(String? url) {
      if (url == null || url.isEmpty) return null;
      
      // If it's already a valid web URL (e.g. Cloudinary), return it
      if (url.startsWith('http')) return url;

      // If it looks like a local file path or relative path
      String cleanPath = url;
      if (url.startsWith('file://')) {
        cleanPath = url.replaceFirst('file://', '');
      }
      
      // Prepend your backend domain to make it a valid NetworkImage URL
      // Note: Ensure this matches your actual backend domain root
      return 'https://backend-fj0v.onrender.com$cleanPath';
    }
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      admno: json['student_no'], // Map API snake_case to Dart camelCase
      phoneNumber: json['phone_number'],
      koinScore: json['koin_score'],
      profilePicture: getValidProfileUrl(json['profile_picture']),
    );
  }
}
