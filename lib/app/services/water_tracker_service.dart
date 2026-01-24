import 'package:get_storage/get_storage.dart';
import '../models/water_intake_log.dart';

class WaterTrackerService {
  static const String _storageKey = 'water_intake_logs';
  final _storage = GetStorage();

  // Save today's water log
  Future<void> saveTodayLog(WaterIntakeLog log) async {
    final logs = await getAllLogs();

    // Remove existing log for today if any
    logs.removeWhere((l) => _isSameDay(l.date, log.date));

    // Add new log
    logs.add(log);

    // Sort by date (newest first)
    logs.sort((a, b) => b.date.compareTo(a.date));

    // Keep only last 90 days
    if (logs.length > 90) {
      logs.removeRange(90, logs.length);
    }

    // Save to storage
    final jsonList = logs.map((l) => l.toJson()).toList();
    await _storage.write(_storageKey, jsonList);
  }

  // Get all logs
  Future<List<WaterIntakeLog>> getAllLogs() async {
    final jsonList = _storage.read<List>(_storageKey);
    if (jsonList == null) return [];

    return jsonList.map((json) => WaterIntakeLog.fromJson(json)).toList();
  }

  // Get today's log
  Future<WaterIntakeLog?> getTodayLog() async {
    final logs = await getAllLogs();
    final today = DateTime.now();

    return logs.firstWhereOrNull((log) => _isSameDay(log.date, today));
  }

  // Get logs for last N days
  Future<List<WaterIntakeLog>> getLogsForLastDays(int days) async {
    final logs = await getAllLogs();
    final cutoffDate = DateTime.now().subtract(Duration(days: days));

    return logs.where((log) => log.date.isAfter(cutoffDate)).toList();
  }

  // Calculate average consumption
  Future<double> getAverageConsumption({int days = 7}) async {
    final logs = await getLogsForLastDays(days);
    if (logs.isEmpty) return 0;

    final total = logs.fold<int>(0, (sum, log) => sum + log.glassesConsumed);
    return total / logs.length;
  }

  // Get best day
  Future<WaterIntakeLog?> getBestDay({int days = 30}) async {
    final logs = await getLogsForLastDays(days);
    if (logs.isEmpty) return null;

    logs.sort((a, b) => b.glassesConsumed.compareTo(a.glassesConsumed));
    return logs.first;
  }

  // Calculate current streak
  Future<int> getCurrentStreak() async {
    final logs = await getAllLogs();
    if (logs.isEmpty) return 0;

    // Sort by date (newest first)
    logs.sort((a, b) => b.date.compareTo(a.date));

    int streak = 0;
    DateTime checkDate = DateTime.now();

    for (var log in logs) {
      if (_isSameDay(log.date, checkDate)) {
        if (log.isGoalAchieved) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else {
          break;
        }
      } else if (log.date.isBefore(checkDate)) {
        // Gap in streak
        break;
      }
    }

    return streak;
  }

  // Get total glasses consumed in a period
  Future<int> getTotalGlasses({int days = 7}) async {
    final logs = await getLogsForLastDays(days);
    return logs.fold<int>(0, (sum, log) => sum + log.glassesConsumed);
  }

  // Get percentage of days goal was achieved
  Future<double> getGoalAchievementRate({int days = 30}) async {
    final logs = await getLogsForLastDays(days);
    if (logs.isEmpty) return 0;

    final achievedDays = logs.where((log) => log.isGoalAchieved).length;
    return (achievedDays / logs.length) * 100;
  }

  // Helper method to check if two dates are the same day
  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

// Extension for firstWhereOrNull
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (var element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}
