// lib/core/models/goal_model.dart

class Goal {
  final int id;
  final String name;
  final double targetAmount;
  final double currentAmount;
  final DateTime createdAt;

  Goal({
    required this.id,
    required this.name,
    required this.targetAmount,
    required this.currentAmount,
    required this.createdAt,
  });

  // Helper to calculate progress
  double get progress => (currentAmount / targetAmount).clamp(0.0, 1.0);

  factory Goal.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Parsing goal: $json');
    return Goal(
      id: json['id'],
      name: json['name'],
      // Django's DecimalField is a string, so we must parse it.
      targetAmount: double.parse(json['target_amount']),
      currentAmount: double.parse(json['current_amount']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
