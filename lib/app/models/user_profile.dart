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
  final String? coverImageUrl;
  final DateTime createdAt;
  final int? weeklyWorkoutGoal;
  final int? dailyCalorieGoal;
  final int? dailyStepGoal;
  final bool? notificationsEnabled;
  final bool? darkModeEnabled;
  final int? workoutReminderHour;
  final int? workoutReminderMinute;
  final int? waterReminderHour;
  final int? waterReminderMinute;
  final bool? isPremium;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.age,
    this.height,
    this.weight,
    this.gender,
    this.photoUrl,
    this.coverImageUrl,
    required this.createdAt,
    this.weeklyWorkoutGoal,
    this.dailyCalorieGoal,
    this.dailyStepGoal,
    this.notificationsEnabled,
    this.darkModeEnabled,
    this.workoutReminderHour,
    this.workoutReminderMinute,
    this.waterReminderHour,
    this.waterReminderMinute,
    this.isPremium,
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
      coverImageUrl: map['coverImageUrl'] as String?,
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      weeklyWorkoutGoal: map['weeklyWorkoutGoal'] as int?,
      dailyCalorieGoal: map['dailyCalorieGoal'] as int?,
      dailyStepGoal: map['dailyStepGoal'] as int? ?? 10000,
      notificationsEnabled: map['notificationsEnabled'] as bool? ?? true,
      darkModeEnabled: map['darkModeEnabled'] as bool? ?? false,
      workoutReminderHour: map['workoutReminderHour'] as int? ?? 8,
      workoutReminderMinute: map['workoutReminderMinute'] as int? ?? 0,
      waterReminderHour: map['waterReminderHour'] as int? ?? 10,
      waterReminderMinute: map['waterReminderMinute'] as int? ?? 0,
      isPremium: map['isPremium'] as bool? ?? false,
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
      'coverImageUrl': coverImageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'weeklyWorkoutGoal': weeklyWorkoutGoal,
      'dailyCalorieGoal': dailyCalorieGoal,
      'dailyStepGoal': dailyStepGoal,
      'notificationsEnabled': notificationsEnabled,
      'darkModeEnabled': darkModeEnabled,
      'workoutReminderHour': workoutReminderHour,
      'workoutReminderMinute': workoutReminderMinute,
      'waterReminderHour': waterReminderHour,
      'waterReminderMinute': waterReminderMinute,
      'isPremium': isPremium,
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
    String? coverImageUrl,
    DateTime? createdAt,
    int? weeklyWorkoutGoal,
    int? dailyCalorieGoal,
    int? dailyStepGoal,
    bool? notificationsEnabled,
    bool? darkModeEnabled,
    int? workoutReminderHour,
    int? workoutReminderMinute,
    int? waterReminderHour,
    int? waterReminderMinute,
    bool? isPremium,
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
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      createdAt: createdAt ?? this.createdAt,
      weeklyWorkoutGoal: weeklyWorkoutGoal ?? this.weeklyWorkoutGoal,
      dailyCalorieGoal: dailyCalorieGoal ?? this.dailyCalorieGoal,
      dailyStepGoal: dailyStepGoal ?? this.dailyStepGoal,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      darkModeEnabled: darkModeEnabled ?? this.darkModeEnabled,
      workoutReminderHour: workoutReminderHour ?? this.workoutReminderHour,
      workoutReminderMinute:
          workoutReminderMinute ?? this.workoutReminderMinute,
      waterReminderHour: waterReminderHour ?? this.waterReminderHour,
      waterReminderMinute: waterReminderMinute ?? this.waterReminderMinute,
      isPremium: isPremium ?? this.isPremium,
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
