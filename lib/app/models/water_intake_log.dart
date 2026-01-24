class WaterIntakeLog {
  final DateTime date;
  final int glassesConsumed;
  final int dailyGoal;
  final List<DateTime> timestamps;

  WaterIntakeLog({
    required this.date,
    required this.glassesConsumed,
    required this.dailyGoal,
    required this.timestamps,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'glassesConsumed': glassesConsumed,
      'dailyGoal': dailyGoal,
      'timestamps': timestamps.map((e) => e.toIso8601String()).toList(),
    };
  }

  // Create from JSON
  factory WaterIntakeLog.fromJson(Map<String, dynamic> json) {
    return WaterIntakeLog(
      date: DateTime.parse(json['date']),
      glassesConsumed: json['glassesConsumed'],
      dailyGoal: json['dailyGoal'],
      timestamps: (json['timestamps'] as List<dynamic>)
          .map((e) => DateTime.parse(e))
          .toList(),
    );
  }

  // Helper method to check if goal was achieved
  bool get isGoalAchieved => glassesConsumed >= dailyGoal;

  // Get date without time for comparison
  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  // Get percentage of goal
  double get percentage => (glassesConsumed / dailyGoal).clamp(0.0, 1.0);
}
