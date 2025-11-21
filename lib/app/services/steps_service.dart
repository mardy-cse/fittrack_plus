import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class StepsService extends GetxService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Initialize service
  Future<StepsService> init() async {
    return this;
  }

  // Save daily steps to Firestore
  Future<void> saveDailySteps({
    required String userId,
    required int steps,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(targetDate);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('steps')
          .doc(dateKey)
          .set({
            'steps': steps,
            'date': Timestamp.fromDate(targetDate),
            'updatedAt': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
    } catch (e) {
      rethrow;
    }
  }

  // Get steps for a specific date
  Future<int> getStepsForDate({required String userId, DateTime? date}) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(targetDate);

      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('steps')
          .doc(dateKey)
          .get();

      if (doc.exists && doc.data() != null) {
        return doc.data()!['steps'] as int? ?? 0;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Get weekly steps summary (last 7 days)
  Future<List<int>> getWeeklySummary({required String userId}) async {
    try {
      final now = DateTime.now();
      final List<int> weeklySteps = [];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final steps = await getStepsForDate(userId: userId, date: date);
        weeklySteps.add(steps);
      }

      return weeklySteps;
    } catch (e) {
      return List.filled(7, 0);
    }
  }

  // Get total steps for current week
  Future<int> getWeeklyTotal({required String userId}) async {
    try {
      final weeklySteps = await getWeeklySummary(userId: userId);
      return weeklySteps.fold<int>(0, (sum, steps) => sum + steps);
    } catch (e) {
      return 0;
    }
  }

  // Watch today's steps in real-time
  Stream<int> watchTodaySteps({required String userId}) {
    final dateKey = DateFormat('yyyy-MM-dd').format(DateTime.now());

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('steps')
        .doc(dateKey)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data() != null) {
            return snapshot.data()!['steps'] as int? ?? 0;
          }
          return 0;
        });
  }

  // Get average daily steps for the week
  Future<int> getWeeklyAverage({required String userId}) async {
    try {
      final weeklyTotal = await getWeeklyTotal(userId: userId);
      return (weeklyTotal / 7).round();
    } catch (e) {
      return 0;
    }
  }

  // Delete steps data for a specific date
  Future<void> deleteStepsForDate({
    required String userId,
    DateTime? date,
  }) async {
    try {
      final targetDate = date ?? DateTime.now();
      final dateKey = DateFormat('yyyy-MM-dd').format(targetDate);

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('steps')
          .doc(dateKey)
          .delete();
    } catch (e) {
      rethrow;
    }
  }
}
