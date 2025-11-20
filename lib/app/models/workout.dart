import 'package:cloud_firestore/cloud_firestore.dart';

class Workout {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final String videoUrl;
  final int durationSeconds;
  final String level; // Beginner, Intermediate, Advanced
  final List<String> tags;
  final int duration; // in minutes (for backward compatibility)
  final int calories;
  final String category; // Cardio, Strength, Yoga, etc.
  final List<String> exercises;
  final DateTime createdAt;
  final bool isPremium;

  Workout({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    this.videoUrl = '',
    required this.durationSeconds,
    required this.level,
    this.tags = const [],
    int? duration,
    required this.calories,
    required this.category,
    required this.exercises,
    required this.createdAt,
    this.isPremium = false,
  }) : duration = duration ?? (durationSeconds ~/ 60);

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'videoUrl': videoUrl,
      'durationSeconds': durationSeconds,
      'level': level,
      'tags': tags,
      'duration': duration,
      'calories': calories,
      'category': category,
      'exercises': exercises,
      'createdAt': Timestamp.fromDate(createdAt),
      'isPremium': isPremium,
    };
  }

  // Create from Firestore document
  factory Workout.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Workout(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      videoUrl: data['videoUrl'] ?? '',
      durationSeconds: data['durationSeconds'] ?? (data['duration'] ?? 0) * 60,
      level: data['level'] ?? 'Beginner',
      tags: List<String>.from(data['tags'] ?? []),
      duration: data['duration'],
      calories: data['calories'] ?? 0,
      category: data['category'] ?? '',
      exercises: List<String>.from(data['exercises'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isPremium: data['isPremium'] ?? false,
    );
  }

  // Create from map (for JSON)
  factory Workout.fromMap(Map<String, dynamic> map, String id) {
    return Workout(
      id: id,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      videoUrl: map['videoUrl'] ?? '',
      durationSeconds: map['durationSeconds'] ?? (map['duration'] ?? 0) * 60,
      level: map['level'] ?? 'Beginner',
      tags: List<String>.from(map['tags'] ?? []),
      duration: map['duration'],
      calories: map['calories'] ?? 0,
      category: map['category'] ?? '',
      exercises: List<String>.from(map['exercises'] ?? []),
      createdAt: map['createdAt'] != null 
          ? (map['createdAt'] is Timestamp 
              ? (map['createdAt'] as Timestamp).toDate() 
              : DateTime.parse(map['createdAt']))
          : DateTime.now(),
      isPremium: map['isPremium'] ?? false,
    );
  }

  // Create from JSON (for local data)
  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout.fromMap(json, json['id'] ?? '');
  }

  // Copy with
  Workout copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    String? videoUrl,
    int? durationSeconds,
    String? level,
    List<String>? tags,
    int? duration,
    int? calories,
    String? category,
    List<String>? exercises,
    DateTime? createdAt,
    bool? isPremium,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      videoUrl: videoUrl ?? this.videoUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      level: level ?? this.level,
      tags: tags ?? this.tags,
      duration: duration ?? this.duration,
      calories: calories ?? this.calories,
      category: category ?? this.category,
      exercises: exercises ?? this.exercises,
      createdAt: createdAt ?? this.createdAt,
      isPremium: isPremium ?? this.isPremium,
    );
  }

  // Get formatted duration
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    if (seconds == 0) {
      return '${minutes}m';
    }
    return '${minutes}m ${seconds}s';
  }
}
