import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../models/calorie_goal.dart';
import '../models/daily_calorie_log.dart';

class CalorieGoalService extends GetxService {
  final GetStorage _storage = GetStorage();
  static const String _goalKey = 'calorie_goal';
  static const String _logsKey = 'calorie_logs';

  // Initialize service
  Future<CalorieGoalService> init() async {
    await GetStorage.init();
    return this;
  }

  // Save calorie goal
  Future<void> saveGoal(CalorieGoal goal) async {
    try {
      await _storage.write(_goalKey, goal.toJson());
      debugPrint('✅ Calorie goal saved');
    } catch (e) {
      debugPrint('Error saving calorie goal: $e');
      rethrow;
    }
  }

  // Load current goal
  Future<CalorieGoal?> loadGoal() async {
    try {
      final json = _storage.read<Map<String, dynamic>>(_goalKey);
      if (json == null) return null;
      return CalorieGoal.fromJson(json);
    } catch (e) {
      debugPrint('Error loading calorie goal: $e');
      return null;
    }
  }

  // Save daily log
  Future<void> saveDailyLog(DailyCalorieLog log) async {
    try {
      final logs = await loadLogs();

      // Remove existing log for the same date
      logs.removeWhere(
        (l) =>
            l.date.year == log.date.year &&
            l.date.month == log.date.month &&
            l.date.day == log.date.day,
      );

      // Add new log
      logs.insert(0, log);

      // Keep only last 90 days
      if (logs.length > 90) {
        logs.removeRange(90, logs.length);
      }

      final jsonList = logs.map((l) => l.toJson()).toList();
      await _storage.write(_logsKey, jsonList);

      debugPrint('✅ Daily calorie log saved');
    } catch (e) {
      debugPrint('Error saving daily log: $e');
      rethrow;
    }
  }

  // Load all logs
  Future<List<DailyCalorieLog>> loadLogs() async {
    try {
      final jsonList = _storage.read<List>(_logsKey);
      if (jsonList == null || jsonList.isEmpty) return [];

      return jsonList
          .map((json) => DailyCalorieLog.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('Error loading logs: $e');
      return [];
    }
  }

  // Get today's log
  Future<DailyCalorieLog?> getTodayLog() async {
    try {
      final logs = await loadLogs();
      final today = DateTime.now();

      return logs.firstWhereOrNull(
        (log) =>
            log.date.year == today.year &&
            log.date.month == today.month &&
            log.date.day == today.day,
      );
    } catch (e) {
      debugPrint('Error getting today log: $e');
      return null;
    }
  }

  // Clear goal
  Future<void> clearGoal() async {
    try {
      await _storage.remove(_goalKey);
    } catch (e) {
      debugPrint('Error clearing goal: $e');
      rethrow;
    }
  }

  // Get progress percentage
  Future<double> getProgressPercentage() async {
    try {
      final goal = await loadGoal();
      if (goal == null) return 0.0;

      final todayLog = await getTodayLog();
      if (todayLog == null || todayLog.weight == null) return 0.0;

      final totalWeightToChange = goal.weightToChange.abs();
      if (totalWeightToChange == 0) return 100.0;

      final weightChanged = (goal.currentWeight - todayLog.weight!).abs();
      final progress = (weightChanged / totalWeightToChange) * 100;

      return progress.clamp(0.0, 100.0);
    } catch (e) {
      debugPrint('Error calculating progress: $e');
      return 0.0;
    }
  }
}
