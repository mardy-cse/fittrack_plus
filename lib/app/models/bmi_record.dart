class BMIRecord {
  final double height; // in cm
  final double weight; // in kg
  final double bmi;
  final String category;
  final DateTime date;

  BMIRecord({
    required this.height,
    required this.weight,
    required this.bmi,
    required this.category,
    required this.date,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'bmi': bmi,
      'category': category,
      'date': date.toIso8601String(),
    };
  }

  // Create from JSON
  factory BMIRecord.fromJson(Map<String, dynamic> json) {
    return BMIRecord(
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      category: json['category'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  // Calculate BMI
  static double calculateBMI(double heightInCm, double weightInKg) {
    final heightInMeters = heightInCm / 100;
    return weightInKg / (heightInMeters * heightInMeters);
  }

  // Get BMI category
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi < 25) {
      return 'Normal';
    } else if (bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  // Get category color
  static String getCategoryColor(String category) {
    switch (category) {
      case 'Underweight':
        return 'blue';
      case 'Normal':
        return 'green';
      case 'Overweight':
        return 'orange';
      case 'Obese':
        return 'red';
      default:
        return 'grey';
    }
  }

  // Get health advice
  static String getHealthAdvice(String category) {
    switch (category) {
      case 'Underweight':
        return 'Consider consulting a nutritionist to gain healthy weight. Focus on nutrient-dense foods and strength training.';
      case 'Normal':
        return 'Great! Maintain your healthy lifestyle with regular exercise and balanced diet.';
      case 'Overweight':
        return 'Consider regular exercise and a balanced diet. Aim for 30 minutes of activity daily.';
      case 'Obese':
        return 'Please consult a healthcare professional for personalized guidance. Small, sustainable changes can make a big difference.';
      default:
        return '';
    }
  }

  // Calculate ideal weight range
  static Map<String, double> getIdealWeightRange(double heightInCm) {
    final heightInMeters = heightInCm / 100;
    const minBMI = 18.5;
    const maxBMI = 25.0;

    final minWeight = minBMI * (heightInMeters * heightInMeters);
    final maxWeight = maxBMI * (heightInMeters * heightInMeters);

    return {'min': minWeight, 'max': maxWeight};
  }

  // Get weight difference from ideal range
  static Map<String, dynamic> getWeightStatus(
    double heightInCm,
    double weightInKg,
  ) {
    final range = getIdealWeightRange(heightInCm);
    final minWeight = range['min']!;
    final maxWeight = range['max']!;

    if (weightInKg < minWeight) {
      return {
        'status': 'below',
        'difference': minWeight - weightInKg,
        'message': 'below ideal range',
      };
    } else if (weightInKg > maxWeight) {
      return {
        'status': 'above',
        'difference': weightInKg - maxWeight,
        'message': 'above ideal range',
      };
    } else {
      return {
        'status': 'ideal',
        'difference': 0.0,
        'message': 'within ideal range',
      };
    }
  }
}
