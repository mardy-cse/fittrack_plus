import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../models/workout.dart';

class WorkoutService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize service
  Future<WorkoutService> init() async {
    return this;
  }

  // Load workouts from local JSON file
  Future<List<Workout>> loadLocalWorkouts() async {
    try {
      final String response =
          await rootBundle.loadString('assets/data/sample_workouts.json');
      final List<dynamic> data = json.decode(response);
      return data.map((json) => Workout.fromJson(json)).toList();
    } catch (e) {
      print('Failed to load local workouts: $e');
      return [];
    }
  }

  // Get all workouts
  Future<List<Workout>> getAllWorkouts() async {
    try {
      final snapshot = await _firestore
          .collection('workouts')
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Workout.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch workouts: $e');
    }
  }

  // Get workouts by level
  Future<List<Workout>> getWorkoutsByLevel(String level) async {
    try {
      final snapshot = await _firestore
          .collection('workouts')
          .where('level', isEqualTo: level)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Workout.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch workouts by level: $e');
    }
  }

  // Get workouts by category
  Future<List<Workout>> getWorkoutsByCategory(String category) async {
    try {
      final snapshot = await _firestore
          .collection('workouts')
          .where('category', isEqualTo: category)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Workout.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch workouts by category: $e');
    }
  }

  // Get workout by ID
  Future<Workout?> getWorkoutById(String id) async {
    try {
      final doc = await _firestore.collection('workouts').doc(id).get();

      if (doc.exists) {
        return Workout.fromDocument(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch workout: $e');
    }
  }

  // Stream all workouts (real-time)
  Stream<List<Workout>> watchWorkouts() {
    return _firestore
        .collection('workouts')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Workout.fromDocument(doc)).toList());
  }

  // Stream workouts by level (real-time)
  Stream<List<Workout>> watchWorkoutsByLevel(String level) {
    return _firestore
        .collection('workouts')
        .where('level', isEqualTo: level)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Workout.fromDocument(doc)).toList());
  }

  // Search workouts by title
  Future<List<Workout>> searchWorkouts(String query) async {
    try {
      final snapshot = await _firestore.collection('workouts').get();

      return snapshot.docs
          .map((doc) => Workout.fromDocument(doc))
          .where((workout) =>
              workout.title.toLowerCase().contains(query.toLowerCase()) ||
              workout.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    } catch (e) {
      throw Exception('Failed to search workouts: $e');
    }
  }

  // Get featured workouts (for demo)
  Future<List<Workout>> getFeaturedWorkouts() async {
    try {
      final snapshot = await _firestore
          .collection('workouts')
          .limit(6)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => Workout.fromDocument(doc)).toList();
    } catch (e) {
      throw Exception('Failed to fetch featured workouts: $e');
    }
  }

  // Create new workout (Admin function)
  Future<String> createWorkout(Workout workout) async {
    try {
      final docRef = await _firestore.collection('workouts').add(workout.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create workout: $e');
    }
  }

  // Update workout (Admin function)
  Future<void> updateWorkout(String id, Workout workout) async {
    try {
      await _firestore.collection('workouts').doc(id).update(workout.toMap());
    } catch (e) {
      throw Exception('Failed to update workout: $e');
    }
  }

  // Delete workout (Admin function)
  Future<void> deleteWorkout(String id) async {
    try {
      await _firestore.collection('workouts').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete workout: $e');
    }
  }

  // Batch import workouts from JSON (Admin function)
  Future<void> importWorkoutsFromJson() async {
    try {
      final workouts = await loadLocalWorkouts();
      final batch = _firestore.batch();

      for (final workout in workouts) {
        final docRef = _firestore.collection('workouts').doc();
        batch.set(docRef, workout.toMap());
      }

      await batch.commit();
      print('Successfully imported ${workouts.length} workouts');
    } catch (e) {
      throw Exception('Failed to import workouts: $e');
    }
  }
}
