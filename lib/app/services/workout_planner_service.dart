import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class WorkoutPlannerService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _userId => _auth.currentUser?.uid;

  // Save workout plan to Firestore
  Future<bool> saveWorkoutPlan(Map<String, String> workoutPlan) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_planner')
          .doc('weekly_plan')
          .set({
            'plan': workoutPlan,
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));

      return true;
    } catch (e) {
      debugPrint('Error saving workout plan: $e');
      return false;
    }
  }

  // Load workout plan from Firestore
  Future<Map<String, String>> loadWorkoutPlan() async {
    try {
      if (_userId == null) {
        return {};
      }

      final doc = await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_planner')
          .doc('weekly_plan')
          .get();

      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        if (data['plan'] != null) {
          return Map<String, String>.from(data['plan'] as Map);
        }
      }

      return {};
    } catch (e) {
      debugPrint('Error loading workout plan: $e');
      return {};
    }
  }

  // Delete a specific day from workout plan
  Future<bool> deleteDayPlan(String day) async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_planner')
          .doc('weekly_plan')
          .update({
            'plan.$day': FieldValue.delete(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      return true;
    } catch (e) {
      debugPrint('Error deleting day plan: $e');
      return false;
    }
  }

  // Clear entire workout plan
  Future<bool> clearWorkoutPlan() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      await _firestore
          .collection('users')
          .doc(_userId)
          .collection('workout_planner')
          .doc('weekly_plan')
          .delete();

      return true;
    } catch (e) {
      debugPrint('Error clearing workout plan: $e');
      return false;
    }
  }

  // AI-powered workout plan generation
  Future<Map<String, String>> generateAIWorkoutPlan() async {
    try {
      if (_userId == null) {
        throw Exception('User not authenticated');
      }

      // Get user profile data
      final userDoc = await _firestore.collection('users').doc(_userId).get();

      if (!userDoc.exists) {
        throw Exception('User profile not found');
      }

      final userData = userDoc.data()!;
      final age = userData['age'] as int? ?? 25;
      final weight = userData['weight'] as double? ?? 70.0;
      final height = userData['height'] as double? ?? 170.0;
      final gender = userData['gender'] as String? ?? 'Male';

      // Calculate BMI to determine fitness level
      final heightInMeters = height / 100;
      final bmi = weight / (heightInMeters * heightInMeters);

      // Generate personalized plan based on profile
      Map<String, String> aiPlan = {};

      // Determine workout intensity based on age and BMI
      bool isBeginnerLevel = age > 45 || bmi > 30 || bmi < 18.5;
      bool isIntermediateLevel =
          (age >= 25 && age <= 45) && (bmi >= 18.5 && bmi <= 25);

      if (isBeginnerLevel) {
        // Beginner/Recovery focused plan
        aiPlan = {
          'Monday': 'Light Cardio & Stretching',
          'Tuesday': 'Upper Body (Light Weights)',
          'Wednesday': 'Rest & Recovery',
          'Thursday': 'Lower Body (Bodyweight)',
          'Friday': 'Full Body Yoga',
          'Saturday': 'Walking & Core',
          'Sunday': 'Rest Day',
        };
      } else if (isIntermediateLevel) {
        // Intermediate balanced plan
        aiPlan = {
          'Monday': 'Upper Body Strength',
          'Tuesday': 'Cardio & Core',
          'Wednesday': 'Lower Body Strength',
          'Thursday': 'HIIT Training',
          'Friday': 'Full Body Workout',
          'Saturday': 'Active Recovery - Yoga',
          'Sunday': 'Rest Day',
        };
      } else {
        // Advanced/Athletic plan
        aiPlan = {
          'Monday': 'Heavy Upper Body',
          'Tuesday': 'Cardio Intervals',
          'Wednesday': 'Heavy Lower Body',
          'Thursday': 'Push Day (Chest, Shoulders, Triceps)',
          'Friday': 'Pull Day (Back, Biceps)',
          'Saturday': 'Leg Day & Core',
          'Sunday': 'Active Recovery or Rest',
        };
      }

      // Gender-specific adjustments
      if (gender.toLowerCase() == 'female') {
        // Add more core and lower body focus
        if (aiPlan.containsKey('Wednesday')) {
          aiPlan['Wednesday'] = 'Lower Body & Glutes';
        }
        if (aiPlan.containsKey('Saturday')) {
          aiPlan['Saturday'] = 'Core & Flexibility';
        }
      }

      return aiPlan;
    } catch (e) {
      debugPrint('Error generating AI workout plan: $e');
      // Return a default balanced plan if error occurs
      return {
        'Monday': 'Upper Body',
        'Tuesday': 'Cardio',
        'Wednesday': 'Lower Body',
        'Thursday': 'Rest Day',
        'Friday': 'Full Body',
        'Saturday': 'Active Recovery',
        'Sunday': 'Rest Day',
      };
    }
  }

  Future<WorkoutPlannerService> init() async {
    return this;
  }
}
