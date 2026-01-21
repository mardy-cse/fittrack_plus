import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import '../models/workout_session.dart';

class WorkoutLogService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize service
  Future<WorkoutLogService> init() async {
    return this;
  }

  // Save workout session
  Future<String?> saveWorkoutSession(WorkoutSession session) async {
    try {
      final docRef = await _firestore
          .collection('workout_sessions')
          .add(session.toMap());
      return docRef.id;
    } catch (e) {
      debugPrint('Error saving workout session: $e');
      return null;
    }
  }

  // Update workout session
  Future<bool> updateWorkoutSession(
    String sessionId,
    Map<String, dynamic> updates,
  ) async {
    try {
      await _firestore
          .collection('workout_sessions')
          .doc(sessionId)
          .update(updates);
      return true;
    } catch (e) {
      debugPrint('Error updating workout session: $e');
      return false;
    }
  }

  // Get user's workout sessions
  Future<List<WorkoutSession>> getUserWorkoutSessions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('workout_sessions')
          .where('userId', isEqualTo: userId)
          .get();

      // Sort in memory instead of Firestore to avoid index requirement
      final sessions = snapshot.docs
          .map((doc) => WorkoutSession.fromDocument(doc))
          .toList();

      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return sessions;
    } catch (e) {
      debugPrint('Error fetching workout sessions: $e');
      return [];
    }
  }

  // Get recent workout sessions (last 7 days)
  Future<List<WorkoutSession>> getRecentWorkoutSessions(String userId) async {
    try {
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));
      final snapshot = await _firestore
          .collection('workout_sessions')
          .where('userId', isEqualTo: userId)
          .get();

      // Filter and sort in memory
      final sessions = snapshot.docs
          .map((doc) => WorkoutSession.fromDocument(doc))
          .where((session) => session.createdAt.isAfter(sevenDaysAgo))
          .toList();

      sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return sessions;
    } catch (e) {
      debugPrint('Error fetching recent workout sessions: $e');
      return [];
    }
  }

  // Get total stats for user
  Future<Map<String, int>> getUserStats(String userId) async {
    try {
      final sessions = await getUserWorkoutSessions(userId);

      int totalWorkouts = sessions.where((s) => s.isCompleted).length;
      int totalMinutes = sessions.fold(
        0,
        (total, s) => total + (s.durationSeconds ~/ 60),
      );
      int totalCalories = sessions.fold(
        0,
        (total, s) => total + s.caloriesBurned,
      );

      return {
        'totalWorkouts': totalWorkouts,
        'totalMinutes': totalMinutes,
        'totalCalories': totalCalories,
      };
    } catch (e) {
      debugPrint('Error calculating user stats: $e');
      return {'totalWorkouts': 0, 'totalMinutes': 0, 'totalCalories': 0};
    }
  }

  // Delete workout session
  Future<bool> deleteWorkoutSession(String sessionId) async {
    try {
      await _firestore.collection('workout_sessions').doc(sessionId).delete();
      return true;
    } catch (e) {
      debugPrint('Error deleting workout session: $e');
      return false;
    }
  }

  // Watch user's workout sessions in real-time
  Stream<List<WorkoutSession>> watchUserWorkoutSessions(String userId) {
    return _firestore
        .collection('workout_sessions')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final sessions = snapshot.docs
              .map((doc) => WorkoutSession.fromDocument(doc))
              .toList();

          // Sort by date (newest first)
          sessions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return sessions;
        });
  }
}
