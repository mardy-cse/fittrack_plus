class BMIRecord {
  final double height; // in cm
  final double weight; // in kg
  final int age;
  final String gender; // 'male' or 'female'
  final double bmi;
  final String category;
  final DateTime date;

  BMIRecord({
    required this.height,
    required this.weight,
    required this.age,
    required this.gender,
    required this.bmi,
    required this.category,
    required this.date,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'height': height,
      'weight': weight,
      'age': age,
      'gender': gender,
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
      age: json['age'] as int,
      gender: json['gender'] as String,
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
        return 'Consider consulting a nutritionist to gain healthy weight.';
      case 'Normal':
        return 'Great! Maintain your healthy lifestyle.';
      case 'Overweight':
        return 'Consider regular exercise and a balanced diet.';
      case 'Obese':
        return 'Please consult a healthcare professional for guidance.';
      default:
        return '';
    }
  }
}
