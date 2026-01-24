class DailyCalorieLog {
  final DateTime date;
  final double? weight;
  final int caloriesConsumed;
  final int caloriesBurned;
  final String notes;

  DailyCalorieLog({
    required this.date,
    this.weight,
    required this.caloriesConsumed,
    this.caloriesBurned = 0,
    this.notes = '',
  });

  int get netCalories => caloriesConsumed - caloriesBurned;

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'caloriesConsumed': caloriesConsumed,
      'caloriesBurned': caloriesBurned,
      'notes': notes,
    };
  }

  factory DailyCalorieLog.fromJson(Map<String, dynamic> json) {
    return DailyCalorieLog(
      date: DateTime.parse(json['date'] as String),
      weight: json['weight'] as double?,
      caloriesConsumed: json['caloriesConsumed'] as int,
      caloriesBurned: json['caloriesBurned'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
    );
  }
}
