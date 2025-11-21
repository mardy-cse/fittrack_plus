import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
      print('Error saving workout plan: $e');
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
      print('Error loading workout plan: $e');
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
      print('Error deleting day plan: $e');
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
      print('Error clearing workout plan: $e');
      return false;
    }
  }

  Future<WorkoutPlannerService> init() async {
    return this;
  }
}
