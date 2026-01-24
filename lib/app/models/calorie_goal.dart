class CalorieGoal {
  final DateTime startDate;
  final double currentWeight;
  final double targetWeight;
  final String goalType; // 'lose', 'gain', 'maintain'
  final int timelineWeeks;
  final int dailyCalorieTarget;
  final DateTime? targetDate;

  CalorieGoal({
    required this.startDate,
    required this.currentWeight,
    required this.targetWeight,
    required this.goalType,
    required this.timelineWeeks,
    required this.dailyCalorieTarget,
    this.targetDate,
  });

  Map<String, dynamic> toJson() {
    return {
      'startDate': startDate.toIso8601String(),
      'currentWeight': currentWeight,
      'targetWeight': targetWeight,
      'goalType': goalType,
      'timelineWeeks': timelineWeeks,
      'dailyCalorieTarget': dailyCalorieTarget,
      'targetDate': targetDate?.toIso8601String(),
    };
  }

  factory CalorieGoal.fromJson(Map<String, dynamic> json) {
    return CalorieGoal(
      startDate: DateTime.parse(json['startDate'] as String),
      currentWeight: json['currentWeight'] as double,
      targetWeight: json['targetWeight'] as double,
      goalType: json['goalType'] as String,
      timelineWeeks: json['timelineWeeks'] as int,
      dailyCalorieTarget: json['dailyCalorieTarget'] as int,
      targetDate: json['targetDate'] != null
          ? DateTime.parse(json['targetDate'] as String)
          : null,
    );
  }

  double get weightToChange => targetWeight - currentWeight;

  bool get isLosing => goalType == 'lose';
  bool get isGaining => goalType == 'gain';
  bool get isMaintaining => goalType == 'maintain';
}
