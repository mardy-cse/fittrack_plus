import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final int? age;
  final double? height; // in cm
  final double? weight; // in kg
  final String? gender;
  final String? photoUrl;
  final DateTime createdAt;
  final int? weeklyWorkoutGoal;
  final int? dailyCalorieGoal;
  final bool? notificationsEnabled;
  final bool? darkModeEnabled;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.photoUrl,
    required this.createdAt,
    this.weeklyWorkoutGoal,
    this.dailyCalorieGoal,
    this.notificationsEnabled,
    this.darkModeEnabled,
  });

  // Convert from Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      age: map['age'] as int?,
      height: map['height']?.toDouble(),
      weight: map['weight']?.toDouble(),
      gender: map['gender'] as String?,
      photoUrl: map['photoUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      weeklyWorkoutGoal: map['weeklyWorkoutGoal'] as int?,
      dailyCalorieGoal: map['dailyCalorieGoal'] as int?,
      notificationsEnabled: map['notificationsEnabled'] as bool?,
      darkModeEnabled: map['darkModeEnabled'] as bool?,
    );
  }

  // Convert from Firestore DocumentSnapshot
  factory UserProfile.fromSnapshot(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile.fromMap(data);
  }

  // Convert to Firestore document
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'age': age,
      'height': height,
      'weight': weight,
      'gender': gender,
      'photoUrl': photoUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'weeklyWorkoutGoal': weeklyWorkoutGoal,
      'dailyCalorieGoal': dailyCalorieGoal,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
    };
  }

  // Create a copy with modifications
  UserProfile copyWith({
    String? uid,
    String? name,
    String? email,
    int? age,
    double? height,
    double? weight,
    String? gender,
    String? photoUrl,
    DateTime? createdAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      age: age ?? this.age,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      gender: gender ?? this.gender,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  // Calculate BMI
  double? get bmi {
    if (height != null && weight != null && height! > 0) {
      final heightInMeters = height! / 100;
      return weight! / (heightInMeters * heightInMeters);
    }
    return null;
  }

  // Get BMI category
  String get bmiCategory {
    final bmiValue = bmi;
    if (bmiValue == null) return 'N/A';

    if (bmiValue < 18.5) return 'Underweight';
    if (bmiValue < 25) return 'Normal';
    if (bmiValue < 30) return 'Overweight';
    return 'Obese';
  }

  @override
  String toString() {
    return 'UserProfile(uid: $uid, name: $name, email: $email, age: $age, height: $height, weight: $weight, gender: $gender)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is UserProfile &&
        other.uid == uid &&
        other.name == name &&
        other.email == email &&
        other.age == age &&
        other.height == height &&
        other.weight == weight &&
        other.gender == gender &&
        other.photoUrl == photoUrl &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return uid.hashCode ^
        name.hashCode ^
        email.hashCode ^
        age.hashCode ^
        height.hashCode ^
        weight.hashCode ^
        gender.hashCode ^
        photoUrl.hashCode ^
        createdAt.hashCode;
  }
}
