class BodyMeasurement {
  final DateTime date;
  final double? weight;
  final double? chest;
  final double? waist;
  final double? hips;
  final double? biceps;
  final double? thighs;
  final double? calves;

  BodyMeasurement({
    required this.date,
    this.weight,
    this.chest,
    this.waist,
    this.hips,
    this.biceps,
    this.thighs,
    this.calves,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date.toIso8601String(),
      'weight': weight,
      'chest': chest,
      'waist': waist,
      'hips': hips,
      'biceps': biceps,
      'thighs': thighs,
      'calves': calves,
    };
  }

  factory BodyMeasurement.fromJson(Map<String, dynamic> json) {
    return BodyMeasurement(
      date: DateTime.parse(json['date'] as String),
      weight: json['weight'] as double?,
      chest: json['chest'] as double?,
      waist: json['waist'] as double?,
      hips: json['hips'] as double?,
      biceps: json['biceps'] as double?,
      thighs: json['thighs'] as double?,
      calves: json['calves'] as double?,
    );
  }
}
