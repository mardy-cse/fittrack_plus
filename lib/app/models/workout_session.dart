import 'package:cloud_firestore/cloud_firestore.dart';

class WorkoutSession {
  final String? id;
  final String workoutId;
  final String workoutTitle;
  final String userId;
  final DateTime startTime;
  final DateTime? endTime;
  final int durationSeconds;
  final int caloriesBurned;
  final int exercisesCompleted;
  final int totalExercises;
  final bool isCompleted;
  final List<String> completedExercises;
  final DateTime createdAt;

  WorkoutSession({
    this.id,
    required this.workoutId,
    required this.workoutTitle,
    required this.userId,
    required this.startTime,
    this.endTime,
    required this.durationSeconds,
    required this.caloriesBurned,
    required this.exercisesCompleted,
    required this.totalExercises,
    this.isCompleted = false,
    this.completedExercises = const [],
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'workoutId': workoutId,
      'workoutTitle': workoutTitle,
      'userId': userId,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': endTime != null ? Timestamp.fromDate(endTime!) : null,
      'durationSeconds': durationSeconds,
      'caloriesBurned': caloriesBurned,
      'exercisesCompleted': exercisesCompleted,
      'totalExercises': totalExercises,
      'isCompleted': isCompleted,
      'completedExercises': completedExercises,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Create from Firestore document
  factory WorkoutSession.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return WorkoutSession(
      id: doc.id,
      workoutId: data['workoutId'] ?? '',
      workoutTitle: data['workoutTitle'] ?? '',
      userId: data['userId'] ?? '',
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: data['endTime'] != null
          ? (data['endTime'] as Timestamp).toDate()
          : null,
      durationSeconds: data['durationSeconds'] ?? 0,
      caloriesBurned: data['caloriesBurned'] ?? 0,
      exercisesCompleted: data['exercisesCompleted'] ?? 0,
      totalExercises: data['totalExercises'] ?? 0,
      isCompleted: data['isCompleted'] ?? false,
      completedExercises: List<String>.from(data['completedExercises'] ?? []),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Create a copy with updated fields
  WorkoutSession copyWith({
    String? id,
    String? workoutId,
    String? workoutTitle,
    String? userId,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    int? caloriesBurned,
    int? exercisesCompleted,
    int? totalExercises,
    bool? isCompleted,
    List<String>? completedExercises,
    DateTime? createdAt,
  }) {
    return WorkoutSession(
      id: id ?? this.id,
      workoutId: workoutId ?? this.workoutId,
      workoutTitle: workoutTitle ?? this.workoutTitle,
      userId: userId ?? this.userId,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      exercisesCompleted: exercisesCompleted ?? this.exercisesCompleted,
      totalExercises: totalExercises ?? this.totalExercises,
      isCompleted: isCompleted ?? this.isCompleted,
      completedExercises: completedExercises ?? this.completedExercises,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
