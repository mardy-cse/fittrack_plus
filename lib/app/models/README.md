# Models

## Purpose
This folder contains data models (DTOs - Data Transfer Objects) that represent the structure of data used throughout the application.

Models define the shape of objects like User, Workout, Exercise, Nutrition entries, etc.

## Structure
```
models/
├── user_model.dart
├── workout_model.dart
├── exercise_model.dart
├── nutrition_model.dart
├── progress_model.dart
└── goal_model.dart
```

## Example Usage

```dart
class WorkoutModel {
  final String id;
  final String userId;
  final String name;
  final String category;
  final int duration;
  final List<ExerciseModel> exercises;
  final DateTime createdAt;
  
  WorkoutModel({
    required this.id,
    required this.userId,
    required this.name,
    required this.category,
    required this.duration,
    required this.exercises,
    required this.createdAt,
  });
  
  // Convert from Firestore
  factory WorkoutModel.fromMap(Map<String, dynamic> map) {
    return WorkoutModel(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      duration: map['duration'] ?? 0,
      exercises: (map['exercises'] as List)
          .map((e) => ExerciseModel.fromMap(e))
          .toList(),
      createdAt: DateTime.parse(map['createdAt']),
    );
  }
  
  // Convert to Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'category': category,
      'duration': duration,
      'exercises': exercises.map((e) => e.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
  
  // Create a copy with modifications
  WorkoutModel copyWith({
    String? name,
    int? duration,
    List<ExerciseModel>? exercises,
  }) {
    return WorkoutModel(
      id: this.id,
      userId: this.userId,
      name: name ?? this.name,
      category: this.category,
      duration: duration ?? this.duration,
      exercises: exercises ?? this.exercises,
      createdAt: this.createdAt,
    );
  }
}
```

## Best Practices
- Use immutable models (final fields)
- Include `fromMap()` factory constructor for deserialization
- Include `toMap()` method for serialization
- Add `copyWith()` method for creating modified copies
- Use descriptive property names
- Add validation in constructors if needed
- Consider using `@JsonSerializable()` for complex models
- Include toString() for debugging
